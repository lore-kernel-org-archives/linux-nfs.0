Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932729Ab3DBVqU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 17:46:20 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 18/19] NFSv4.2: Added v4.2 error codes
Date: Tue,  2 Apr 2013 17:45:59 -0400
Message-Id: <1364939160-20874-19-git-send-email-SteveD@redhat.com>
In-Reply-To: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfsd/nfs4xdr.c    | 2 +-
 fs/nfsd/nfsd.h       | 6 ++++++
 fs/nfsd/nfsproc.c    | 1 +
 include/linux/nfs4.h | 8 ++++++++
 4 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5d06d08..818c1ca 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -90,7 +90,7 @@ static struct nfs4_label *nfsd4_label_alloc(u32 len)
 	struct nfs4_label *label = NULL;
 
 	if (len > NFS4_MAXLABELLEN)
-		return ERR_PTR(-ENAMETOOLONG);
+		return ERR_PTR(-EMSGSIZE);
 
 	label = kzalloc(len + sizeof(struct nfs4_label), GFP_KERNEL);
 	if (label == NULL)
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 62dc89b..3090561 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -243,6 +243,12 @@ void		nfsd_lockd_shutdown(void);
 #define nfserr_reject_deleg		cpu_to_be32(NFS4ERR_REJECT_DELEG)
 #define nfserr_returnconflict		cpu_to_be32(NFS4ERR_RETURNCONFLICT)
 #define nfserr_deleg_revoked		cpu_to_be32(NFS4ERR_DELEG_REVOKED)
+#define nfserr_partner_notsupp		cpu_to_be32(NFS4ERR_PARTNER_NOTSUPP)
+#define nfserr_partner_no_auth		cpu_to_be32(NFS4ERR_PARTNER_NO_AUTH)
+#define nfserr_metadata_notsupp		cpu_to_be32(NFS4ERR_METADATA_NOTSUPP)
+#define nfserr_offload_denied		cpu_to_be32(NFS4ERR_OFFLOAD_DENIED)
+#define nfserr_wrong_lfs		cpu_to_be32(NFS4ERR_WRONG_LFS)
+#define nfs4err_badlabel		cpu_to_be32(NFS4ERR_BADLABEL)
 
 /* error codes for internal use */
 /* if a request fails due to kmalloc failure, it gets dropped.
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 54c6b3d..85289a5 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -743,6 +743,7 @@ nfserrno (int errno)
 		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ nfserr_toosmall, -ETOOSMALL },
 		{ nfserr_serverfault, -ESERVERFAULT },
+		{ nfs4err_badlabel, -EMSGSIZE },
 	};
 	int	i;
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 445792a..4c61ef4 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -226,6 +226,14 @@ enum nfsstat4 {
 	NFS4ERR_REJECT_DELEG	= 10085,	/* on callback */
 	NFS4ERR_RETURNCONFLICT	= 10086,	/* outstanding layoutreturn */
 	NFS4ERR_DELEG_REVOKED	= 10087,	/* deleg./layout revoked */
+
+	/* nfs42 */
+	NFS4ERR_PARTNER_NOTSUPP	= 10088,
+	NFS4ERR_PARTNER_NO_AUTH	= 10089,
+	NFS4ERR_METADATA_NOTSUPP = 10090,
+	NFS4ERR_OFFLOAD_DENIED = 10091,
+	NFS4ERR_WRONG_LFS = 10092,
+	NFS4ERR_BADLABEL = 10093,
 };
 
 static inline bool seqid_mutating_err(u32 err)
-- 
1.8.1.4

