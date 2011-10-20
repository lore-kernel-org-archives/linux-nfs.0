Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45538 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085Ab1JTCNR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2011 22:13:17 -0400
Received: by mail-yw0-f46.google.com with SMTP id 7so2323875ywf.19
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 19:13:17 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 4/7] nfsd4: allow NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL | NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED
Date: Wed, 19 Oct 2011 19:13:13 -0700
Message-Id: <1319076793-13429-1-git-send-email-benny@tonian.com>
In-Reply-To: <4E9F82FC.2000904@tonian.com>
References: <4E9F82FC.2000904@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

RFC5661 says:
   The client may set one or both of
   OPEN4_SHARE_ACCESS_WANT_SIGNAL_DELEG_WHEN_RESRC_AVAIL and
   OPEN4_SHARE_ACCESS_WANT_PUSH_DELEG_WHEN_UNCONTENDED.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4xdr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fdc09a5..706ada1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -677,6 +677,8 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
 	switch (w) {
 	case NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL:
 	case NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED:
+	case (NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL |
+	      NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED):
 		return nfs_ok;
 	}
 xdr_error:
-- 
1.7.6

