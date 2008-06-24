From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC] nfs: initialize timeout variable in nfs4_proc_setclientid_confirm
Date: Tue, 24 Jun 2008 20:25:57 +0300
Message-ID: <48612E25.8050405@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:48885 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbYFXR0E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 13:26:04 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1414086tic.23
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jun 2008 10:26:02 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gcc (4.3.0) rightfully warns about this:
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/nfs4proc.c: In =
function =91nfs4_proc_setclientid_confirm=92:
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/nfs4proc.c:2936=
: warning: =91timeout=92 may be used uninitialized in this function

nfs4_delay that's passed a pointer to 'timeout' is looking at its value
and sets it up to some value in the range: NFS4_POLL_RETRY_MIN..NFS4_PO=
LL_RETRY_MAX
	if (*timeout <=3D 0)
		*timeout =3D NFS4_POLL_RETRY_MIN;
	if (*timeout > NFS4_POLL_RETRY_MAX)
		*timeout =3D NFS4_POLL_RETRY_MAX;

Therefore it will end up set to some sane, though rather indeterministi=
c, value.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---

Trond, this patch merely initializes timeout to 0 which will
result in it set eventually to NFS4_POLL_RETRY_MIN.
Is this appropriate?

Benny

 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1293e0a..39981b6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2933,7 +2933,7 @@ static int _nfs4_proc_setclientid_confirm(struct =
nfs_client *clp, struct rpc_cre
=20
 int nfs4_proc_setclientid_confirm(struct nfs_client *clp, struct rpc_c=
red *cred)
 {
-	long timeout;
+	long timeout =3D 0;
 	int err;
 	do {
 		err =3D _nfs4_proc_setclientid_confirm(clp, cred);
--=20
1.5.6.GIT

