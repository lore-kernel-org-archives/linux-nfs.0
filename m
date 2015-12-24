Return-Path: <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfsstat: show client rpc information correctly
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com, Benjamin Coddington <bcodding@redhat.com>
Message-ID: <567BE110.3070406@gmail.com>
Date: Thu, 24 Dec 2015 20:12:00 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

There are 59 client rpc procedures, not 60.

The order of rpc name must be the same as define of
NFSPROC4_CLNT_xx in include/linux/nfs4.h,
not nfs4_procedures in nfs4xdr.c.

Drop duplicate rpc name "getdevlist".

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/nfsstat/nfsstat.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index b67f0aa..8376347 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -31,7 +31,7 @@ enum {
 	SRVPROC3_SZ = 22,
 	CLTPROC3_SZ = 22,
 	SRVPROC4_SZ = 2,
-	CLTPROC4_SZ = 60,
+	CLTPROC4_SZ = 59,
 	SRVPROC4OPS_SZ = 71,
 };
 
@@ -135,11 +135,10 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
 	"sequence",
 	"get_lease_time",
 	"reclaim_comp",
-	"getdevinfo",
 	"layoutget",
+	"getdevinfo",
 	"layoutcommit",
 	"layoutreturn",
-	"getdevlist",
 	"secinfo_no",
 	"test_stateid",
 	"free_stateid",
-- 
2.5.0
