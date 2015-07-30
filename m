Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50813 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbbG3DBZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jul 2015 23:01:25 -0400
Date: Thu, 30 Jul 2015 13:00:56 +1000
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4: don't set SETATTR for O_RDONLY|O_EXCL
Message-ID: <20150730130056.541f1a5e@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


It is unusual to combine the open flags O_RDONLY and O_EXCL, but
it appears that libre-office does just that.

[pid  3250] stat("/home/USER/.config", {st_mode=S_IFDIR|0700, st_size=8192, ...}) = 0
[pid  3250] open("/home/USER/.config/libreoffice/4-suse/user/extensions/buildid", O_RDONLY|O_EXCL <unfinished ...>

NFSv4 takes O_EXCL as a sign that a setattr command should be sent,
probably to reset the timestamps.

When it was an O_RDONLY open, the SETATTR command does not
identify any actual attributes to change.
If no delegation was provided to the open, the SETATTR uses the
all-zeros stateid and the request is accepted (at least by the
Linux NFS server - no harm, no foul).

If a read-delegation was provided, this is used in the SETATTR
request, and a Netapp filer will justifiably claim
NFS4ERR_BAD_STATEID, which the Linux client takes as a sign
to retry - indefinitely.

So only treat O_EXCL specially if O_CREAT was also given.

Signed-off-by: NeilBrown <neilb@suse.com>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8bee93469617..4c1c591103b1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2412,7 +2412,7 @@ static int _nfs4_do_open(struct inode *dir,
 		goto err_free_label;
 	state = ctx->state;
 
-	if ((opendata->o_arg.open_flags & O_EXCL) &&
+	if ((opendata->o_arg.open_flags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL) &&
 	    (opendata->o_arg.createmode != NFS4_CREATE_GUARDED)) {
 		nfs4_exclusive_attrset(opendata, sattr);
 
