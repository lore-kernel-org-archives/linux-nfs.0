From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 14/35] pnfsd: filelayout: layout encoding
Date: Mon,  7 Dec 2009 11:32:53 +0200
Message-ID: <1260178373-15152-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Andy Adamson <andros@netapp.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[extracted from: pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: update pNFS server ops to draft 13]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: Check for dense layout in layout encode.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: Fix server GETDEVICELIST to comply with NFSv4.1 Draft 13]
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
[pnfsd: Fix file layout layoutget export op for d13]
[pnfsd: Simplify layout get export interface.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: improve nfs4_pnfs_get_layout dprintks]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: initialize layoutget return_on_close]
Signed-off-by: Andy Adamson<andros@netapp.com>
[pnfsd: Use 128 bit deviceid on server]
[pnfsd: update server layout xdr for draft 19.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: filelayout: use nfsd4_compoundres pointer in pnfs_xdr_info]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: filelayout: get rid of xdr encoding macros for file layout xdr]
[pnfsd: get rid of layout encoding function vector]
[pnfsd: filelayout: strictly define filelayout_encode_layout]
[pnfsd: filelayout: convert to using exp_xdr]
[include nfsd4_pnfs.h from nfs4layoutxdr.h for deviceid_t]
[pnfsd: rename deviceid_t struct pnfs_deviceid]
[pnfsd: fix cosmetic checkpatch warnings]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/exportfs/nfs4filelayoutxdr.c    |   86 ++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/nfs4layoutxdr.h |   18 ++++++++
 2 files changed, 104 insertions(+), 0 deletions(-)

diff --git a/fs/exportfs/nfs4filelayoutxdr.c b/fs/exportfs/nfs4filelayoutxdr.c
index b9c24d2..d7ceb72 100644
--- a/fs/exportfs/nfs4filelayoutxdr.c
+++ b/fs/exportfs/nfs4filelayoutxdr.c
@@ -30,6 +30,9 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 #include <linux/exp_xdr.h>
+#include <linux/module.h>
+#include <linux/nfs4.h>
+#include <linux/nfsd/nfsfh.h>
 #include <linux/nfsd/nfs4layoutxdr.h>
 
 /* We do our-own dprintk so filesystems are not dependent on sunrpc */
@@ -130,3 +133,86 @@ out:
 	return error;
 }
 EXPORT_SYMBOL(filelayout_encode_devinfo);
+
+/* Encodes the loc_body structure from draft 13
+ * on the response stream.
+ * Use linux error codes (not nfs) since these values are being
+ * returned to the file system.
+ */
+int
+filelayout_encode_layout(struct exp_xdr_stream *xdr,
+			 const struct pnfs_filelayout_layout *flp)
+{
+	u32 len = 0, nfl_util, fhlen, i;
+	u32 *layoutlen_p;
+	int error;
+	__be32 *p;
+
+	dprintk("%s: device_id %llx:%llx fsi %u, numfh %u\n",
+		__func__,
+		flp->device_id.pnfs_fsid,
+		flp->device_id.pnfs_devid,
+		flp->lg_first_stripe_index,
+		flp->lg_fh_length);
+
+	/* Ensure file system added at least one file handle */
+	if (flp->lg_fh_length <= 0) {
+		dprintk("%s: File Layout has no file handles!!\n", __func__);
+		error = -NFS4ERR_LAYOUTUNAVAILABLE;
+		goto out;
+	}
+
+	/* Ensure room for len, devid, util, first_stripe_index,
+	 * pattern_offset, number of filehandles */
+	p = layoutlen_p = exp_xdr_reserve_qwords(xdr, 1+2+2+1+1+2+1);
+	if (!p) {
+		error = -ETOOSMALL;
+		goto out;
+	}
+
+	/* save spot for opaque file layout length, fill-in later*/
+	p++;
+
+	/* encode device id */
+	p = exp_xdr_encode_u64(p, flp->device_id.fsid);
+	p = exp_xdr_encode_u64(p, flp->device_id.devid);
+
+	/* set and encode flags */
+	nfl_util = flp->lg_stripe_unit;
+	if (flp->lg_commit_through_mds)
+		nfl_util |= NFL4_UFLG_COMMIT_THRU_MDS;
+	if (flp->lg_stripe_type == STRIPE_DENSE)
+		nfl_util |= NFL4_UFLG_DENSE;
+	p = exp_xdr_encode_u32(p, nfl_util);
+
+	/* encode first stripe index */
+	p = exp_xdr_encode_u32(p, flp->lg_first_stripe_index);
+
+	/* encode striping pattern start */
+	p = exp_xdr_encode_u64(p, flp->lg_pattern_offset);
+
+	/* encode number of file handles */
+	p = exp_xdr_encode_u32(p, flp->lg_fh_length);
+
+	/* encode file handles */
+	for (i = 0; i < flp->lg_fh_length; i++) {
+		fhlen = flp->lg_fh_list[i].fh_size;
+		p = exp_xdr_reserve_space(xdr, 4 + fhlen);
+		if (!p) {
+			error = -ETOOSMALL;
+			goto out;
+		}
+		p = exp_xdr_encode_opaque(p, &flp->lg_fh_list[i].fh_base, fhlen);
+	}
+
+	/* Set number of bytes encoded =  total_bytes_encoded - length var */
+	len = (char *)p - (char *)layoutlen_p;
+	exp_xdr_encode_u32(layoutlen_p, len - 4);
+
+	error = 0;
+out:
+	dprintk("%s: End err %d xdrlen %d\n",
+		__func__, error, len);
+	return error;
+}
+EXPORT_SYMBOL(filelayout_encode_layout);
diff --git a/include/linux/nfsd/nfs4layoutxdr.h b/include/linux/nfsd/nfs4layoutxdr.h
index 5da0c74..26fddd5 100644
--- a/include/linux/nfsd/nfs4layoutxdr.h
+++ b/include/linux/nfsd/nfs4layoutxdr.h
@@ -35,6 +35,7 @@
 #define NFSD_NFS4LAYOUTXDR_H
 
 #include <linux/sunrpc/xdr.h>
+#include <linux/nfsd/nfsd4_pnfs.h>
 
 /* the nfsd4_pnfs_devlist dev_addr for the file layout type */
 struct pnfs_filelayout_devaddr {
@@ -55,4 +56,21 @@ struct pnfs_filelayout_device {
 	struct pnfs_filelayout_multipath 	*fl_device_list;
 };
 
+struct pnfs_filelayout_layout {
+	u32                             lg_layout_type; /* response */
+	u32                             lg_stripe_type; /* response */
+	u32                             lg_commit_through_mds; /* response */
+	u64                             lg_stripe_unit; /* response */
+	u64                             lg_pattern_offset; /* response */
+	u32                             lg_first_stripe_index;	/* response */
+	struct nfsd4_pnfs_deviceid	device_id;		/* response */
+	u32                             lg_fh_length;		/* response */
+	struct knfsd_fh                 *lg_fh_list;		/* response */
+};
+
+enum stripetype4 {
+	STRIPE_SPARSE = 1,
+	STRIPE_DENSE = 2
+};
+
 #endif /* NFSD_NFS4LAYOUTXDR_H */
-- 
1.6.5.1

