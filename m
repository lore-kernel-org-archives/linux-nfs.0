Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27851 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751050Ab2BQUUl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 15:20:41 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/3] NFSv4: Send implementation id with exchange_id
Date: Fri, 17 Feb 2012 15:20:24 -0500
Message-Id: <1329510026-30403-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Send the nfs implementation id in EXCHANGE_ID requests unless the module
parameter nfs.send_implementation_id is 0.

This adds a CONFIG variable for the nii_domain that defaults to "kernel.org".

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
Update: Applied Trond's comments

 Documentation/kernel-parameters.txt |    9 +++++++
 fs/nfs/Kconfig                      |   12 ++++++++++
 fs/nfs/nfs4xdr.c                    |   41 +++++++++++++++++++++++++++++++++-
 3 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 1d369c6..7bae0fd 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1678,6 +1678,15 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			back to using the idmapper.
 			To turn off this behaviour, set the value to '0'.
 
+	nfs.send_implementation_id =
+			[NFSv4.1] Send client implementation identification
+			information in exchange_id requests.
+			If zero, no implementation identification information
+			will be sent.
+			The default is to send the implementation identification
+			information.
+
+
 	nmi_debug=	[KNL,AVR32,SH] Specify one or more actions to take
 			when a NMI is triggered.
 			Format: [state][,regs][,debounce][,die]
diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index ee86cfc..7bce64c 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -99,6 +99,18 @@ config PNFS_OBJLAYOUT
 	depends on NFS_FS && NFS_V4_1 && SCSI_OSD_ULD
 	default m
 
+config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
+	string "NFSv4.1 Implementation ID Domain"
+	depends on NFS_V4_1
+	default "kernel.org"
+	help
+	  This option defines the domain portion of the implementation ID that
+	  may be sent in the NFS exchange_id operation.  The value must be in
+	  the format of a DNS domain name and should be set to the DNS domain
+	  name of the distribution.
+	  If the NFS client is unchanged from the upstream kernel, this
+	  option should be set to the default "kernel.org".
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ae78343..d824aed 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -44,6 +44,8 @@
 #include <linux/pagemap.h>
 #include <linux/proc_fs.h>
 #include <linux/kdev_t.h>
+#include <linux/module.h>
+#include <linux/utsname.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/gss_api.h>
@@ -271,7 +273,12 @@ static int nfs4_stat_to_errno(int);
 				1 /* flags */ + \
 				1 /* spa_how */ + \
 				0 /* SP4_NONE (for now) */ + \
-				1 /* zero implemetation id array */)
+				1 /* implementation id array of size 1 */ + \
+				1 /* nii_domain */ + \
+				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
+				1 /* nii_name */ + \
+				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
+				3 /* nii_date */)
 #define decode_exchange_id_maxsz (op_decode_hdr_maxsz + \
 				2 /* eir_clientid */ + \
 				1 /* eir_sequenceid */ + \
@@ -838,6 +845,12 @@ const u32 nfs41_maxread_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				    XDR_UNIT);
 #endif /* CONFIG_NFS_V4_1 */
 
+static unsigned short send_implementation_id = 1;
+
+module_param(send_implementation_id, ushort, 0644);
+MODULE_PARM_DESC(send_implementation_id,
+		"Send implementation ID with NFSv4.1 exchange_id");
+
 static const umode_t nfs_type2fmt[] = {
 	[NF4BAD] = 0,
 	[NF4REG] = S_IFREG,
@@ -1766,6 +1779,8 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 			       struct compound_hdr *hdr)
 {
 	__be32 *p;
+	char impl_name[NFS4_OPAQUE_LIMIT];
+	int len = 0;
 
 	p = reserve_space(xdr, 4 + sizeof(args->verifier->data));
 	*p++ = cpu_to_be32(OP_EXCHANGE_ID);
@@ -1776,7 +1791,29 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(args->flags);
 	*p++ = cpu_to_be32(0);	/* zero length state_protect4_a */
-	*p = cpu_to_be32(0);	/* zero length implementation id array */
+
+	if (send_implementation_id &&
+	    sizeof(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN) > 1 &&
+	    sizeof(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN)
+		<= NFS4_OPAQUE_LIMIT + 1)
+		len = snprintf(impl_name, sizeof(impl_name), "%s %s %s %s",
+			       utsname()->sysname, utsname()->release,
+			       utsname()->version, utsname()->machine);
+
+	if (len > 0) {
+		*p = cpu_to_be32(1);	/* implementation id array length=1 */
+
+		encode_string(xdr,
+			sizeof(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN) - 1,
+			CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN);
+		encode_string(xdr, len, impl_name);
+		/* just send zeros for nii_date - the date is in nii_name */
+		p = reserve_space(xdr, 12);
+		p = xdr_encode_hyper(p, 0);
+		*p = cpu_to_be32(0);
+	} else
+		*p = cpu_to_be32(0);	/* implementation id array length=0 */
+
 	hdr->nops++;
 	hdr->replen += decode_exchange_id_maxsz;
 }
-- 
1.7.4.4

