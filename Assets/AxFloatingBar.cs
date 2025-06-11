using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Apeiron
{
//  [ExecuteInEditMode]
    public class AxFloatingBar : MonoBehaviour
    {
        public struct ShadProp
        {
            public static readonly int sizeX     = Shader.PropertyToID("_SizeX");
            public static readonly int sizeY     = Shader.PropertyToID("_SizeY");

            public static readonly int gridRes   = Shader.PropertyToID("_GridResoultion");
            public static readonly int cellX     = Shader.PropertyToID("_CellCountX");
            public static readonly int cellY     = Shader.PropertyToID("_CellCountY");

            public static readonly int healthCol = Shader.PropertyToID("_BarColor1");
            public static readonly int healCol   = Shader.PropertyToID("_BarColor2");
            public static readonly int shieldCol = Shader.PropertyToID("_BarColor3");
            public static readonly int damageCol = Shader.PropertyToID("_BarColor4");

            public static readonly int healthPct = Shader.PropertyToID("_BarPct1");
            public static readonly int healPct   = Shader.PropertyToID("_BarPct2");
            public static readonly int shieldPct = Shader.PropertyToID("_BarPct3");
            public static readonly int damagePct = Shader.PropertyToID("_BarPct4");

        }

        public Material material    = null;
        public float    gridCount   = 1;
        public int      gridRes     = 0;
        public float    scale       = 1;
        public float    healthPct   = 0;
        public float    healPct     = 0;
        public float    shieldPct   = 0;
        public float    damagePct   = 0;

        float cellCount {
            get {
                return gridCount * (gridRes + 1);
            }
        }

//      void OnValidate() { UpdateProperties(); }
        void Awake()
        {
            material = null;
            UpdateProperties();
        }

        public void SetGridCount(float count) {
            gridCount = count;
            UpdateCellSize ();
            UpdateCellCount();
        }

        public void SetCellResolution(int v) {
            gridRes = v;
            UpdateGridResolution();
        }


        public void SetHealthVal(float v) { if (material == null) return; material.SetFloat(ShadProp.healthPct, v); healthPct = v; }
        public void SetHealVal  (float v) { if (material == null) return; material.SetFloat(ShadProp.healPct,   v); healPct   = v; }
        public void SetShieldVal(float v) { if (material == null) return; material.SetFloat(ShadProp.shieldPct, v); shieldPct = v; }
        public void SetDamageVal(float v) { if (material == null) return; material.SetFloat(ShadProp.damagePct, v); damagePct = v; }

        public void SetHealthCol(Color v) { if (material == null) return; material.SetColor(ShadProp.healthCol, v); }
        public void SetHealCol  (Color v) { if (material == null) return; material.SetColor(ShadProp.healCol,   v); }
        public void SetShieldCol(Color v) { if (material == null) return; material.SetColor(ShadProp.shieldCol, v); }
        public void SetDamageCol(Color v) { if (material == null) return; material.SetColor(ShadProp.damageCol, v); }


//      [Sirenix.OdinInspector.Button]
        public void ResetProperties() {
            material = null;
            UpdateProperties();
        }

        void UpdateProperties()
        {
            if (material == null)
            {
                var img = GetComponent<Image>();
                if (img)
                {
                    material = new Material(img.material);
                    img.material = material;
                }
            }

            UpdateCellCount();
            UpdateCellSize();
            UpdateGridResolution();
            UpdateBars();
        }

        void UpdateBars() {
            SetHealthVal(healthPct);
            SetHealVal  (healPct);
            SetShieldVal(shieldPct);
            SetDamageVal(damagePct);
        }

        void UpdateCellSize()
        {
            if (material == null)
                return;
            var r = (transform as RectTransform);
            var s = Vector2.zero;

            s.x = r.rect.size.x / r.rect.size.y / cellCount / scale;
            s.y = 1.0f;

            material.SetFloat(ShadProp.sizeX, s.x);
            material.SetFloat(ShadProp.sizeY, s.y);
        }

        void UpdateCellCount() {
            if (material == null)
                return;
            material.SetFloat(ShadProp.cellX, cellCount);
            material.SetFloat(ShadProp.cellY, 1);
        }

        void UpdateGridResolution() {
            if (material == null)
                return;
            material.SetInteger(ShadProp.gridRes, gridRes);
        }
    }
}

