Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:37472 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753341AbcK0G1q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:46 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 06/12] Add xdr for Flex Files Layout Type
Date: Sat, 26 Nov 2016 22:26:35 -0800
Message-ID: <1480228001-64821-7-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note that unlike the block layout, we don't
create a new file as there are too many
dependencies on existing types.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/xdrdef/nfs4.x | 97 ++++++++++++++++++++++++++++++++++++++++++++++++=
+++-
 1 file changed, 96 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/xdrdef/nfs4.x b/nfs4.1/xdrdef/nfs4.x
index 16870f7..c2c9361 100644
--- a/nfs4.1/xdrdef/nfs4.x
+++ b/nfs4.1/xdrdef/nfs4.x
@@ -572,7 +572,8 @@ struct stateid4 {
 enum layouttype4 {
         LAYOUT4_NFSV4_1_FILES   =3D 0x1,
         LAYOUT4_OSD2_OBJECTS    =3D 0x2,
-        LAYOUT4_BLOCK_VOLUME    =3D 0x3
+        LAYOUT4_BLOCK_VOLUME    =3D 0x3,
+        LAYOUT4_FLEX_FILES      =3D 0x4
 };
=20
 struct layout_content4 {
@@ -3040,6 +3041,100 @@ default:
         void;
 };
=20
+struct ff_device_versions4 {
+        uint32_t        ffdv_version;
+        uint32_t        ffdv_minorversion;
+        uint32_t        ffdv_rsize;
+        uint32_t        ffdv_wsize;
+        bool            ffdv_tightly_coupled;
+};
+
+struct ff_device_addr4 {
+        multipath_list4     ffda_netaddrs;
+        ff_device_versions4 ffda_versions<>;
+};
+
+const FF_FLAGS_NO_LAYOUTCOMMIT   =3D 0x00000001;
+const FF_FLAGS_NO_IO_THRU_MDS    =3D 0x00000002;
+const FF_FLAGS_NO_READ_IO        =3D 0x00000004;
+typedef uint32_t            ff_flags4;
+
+struct ff_data_server4 {
+    deviceid4               ffds_deviceid;
+    uint32_t                ffds_efficiency;
+    stateid4                ffds_stateid;
+    nfs_fh4                 ffds_fh_vers<>;
+    fattr4_owner            ffds_user;
+    fattr4_owner_group      ffds_group;
+};
+
+struct ff_mirror4 {
+    ff_data_server4         ffm_data_servers<>;
+};
+
+struct ff_layout4 {
+    length4                 ffl_stripe_unit;
+    ff_mirror4              ffl_mirrors<>;
+    ff_flags4               ffl_flags;
+    uint32_t                ffl_stats_collect_hint;
+};
+
+struct ff_ioerr4 {
+        offset4        ffie_offset;
+        length4        ffie_length;
+        stateid4       ffie_stateid;
+        device_error4  ffie_errors<>;
+};
+
+struct ff_io_latency4 {
+        uint64_t       ffil_ops_requested;
+        uint64_t       ffil_bytes_requested;
+        uint64_t       ffil_ops_completed;
+        uint64_t       ffil_bytes_completed;
+        uint64_t       ffil_bytes_not_delivered;
+        nfstime4       ffil_total_busy_time;
+        nfstime4       ffil_aggregate_completion_time;
+};
+
+struct ff_layoutupdate4 {
+        netaddr4       ffl_addr;
+        nfs_fh4        ffl_fhandle;
+        ff_io_latency4 ffl_read;
+        ff_io_latency4 ffl_write;
+        nfstime4       ffl_duration;
+        bool           ffl_local;
+};
+
+struct ff_iostats4 {
+        offset4           ffis_offset;
+        length4           ffis_length;
+        stateid4          ffis_stateid;
+        io_info4          ffis_read;
+        io_info4          ffis_write;
+        deviceid4         ffis_deviceid;
+        ff_layoutupdate4  ffis_layoutupdate;
+};
+
+struct ff_layoutreturn4 {
+        ff_ioerr4     fflr_ioerr_report<>;
+        ff_iostats4   fflr_iostats_report<>;
+};
+
+union ff_mirrors_hint switch (bool ffmc_valid) {
+    case TRUE:
+        uint32_t    ffmc_mirrors;
+    case FALSE:
+        void;
+};
+
+struct ff_layouthint4 {
+    ff_mirrors_hint fflh_mirrors_hint;
+};
+
+enum ff_cb_recall_any_mask {
+    FF_RCA4_TYPE_MASK_READ =3D -2,
+    FF_RCA4_TYPE_MASK_RW   =3D -1
+};
=20
 /*
  * Operation arrays (the rest)
--=20
2.3.6

