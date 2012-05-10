Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:55878 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043Ab2EJAS4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2012 20:18:56 -0400
Date: Wed, 9 May 2012 19:18:42 -0500
From: Jonathan Nieder <jrnieder@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>,
        Rik Theys <Rik.Theys@esat.kuleuven.be>,
        David Flyn <davidf@rd.bbc.co.uk>, Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH v2] NFSv4: Save the owner/group name string when doing
 open
Message-ID: <20120510001842.GB8228@burratino>
References: <1325956115-21767-1-git-send-email-Trond.Myklebust@netapp.com>
 <1325960863-31742-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120302050813.GA32761@burratino>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120302050813.GA32761@burratino>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jonathan Nieder wrote:

[...]
> | and then log into machine B and do:
> |
> | vim
> | :q
> |
> | I get E137: Viminfo file is not writable: /users/system/rtheys/.viminfo
> |
> | Every invocation of 'vim and :q' will trigger this.
> |
> | Explicitely doing a stat of the file fixes this.
>
> Rik Theys bisected and found the bug reproducible after and not before
> v2.6.32-rc1~412^2~48^2~15 (NFSv4: Don't do idmapper upcalls for
> asynchronous RPC calls, 2009-08-09).
>
> [...]
>>  6 files changed, 162 insertions(+), 64 deletions(-)
>
> Now I am wondering what, if anything, can be done to fix this in the
> 2.6.32.y, 3.0.y, and 3.2.y stable kernels.  The patch looks too big
> for inclusion under the usual stable_kernel_rules:

Trond had a neat idea for fixing this.  Let's see how easy it is for a
novice like me to understand.

As explained at [1], the problem is that after the OPEN call .viminfo
has the default values for st_uid and st_gid cached (i.e., 0xfffffffe)
because it does not want to let rpciod wait during an idmapper upcall
to fill them in.  The fix used in mainline is to save the owner and
group as strings and perform the upcall in _nfs4_proc_open outside the
rpciod context.

The fix for stable kernels that Trond suggests is to notice when
st_uid and st_gid have not been filled in and perform a separate
GETATTR call.  The patch is nice and small.  My (ignorant) worry: does
nfs4_open_reclaim need the same fix?

[1] http://thread.gmane.org/gmane.linux.nfs/37230/focus=37250
---
Rik, results from testing would be interesting if you have a chance to
try it.  Thanks again for your help, all.

Jonathan

 fs/nfs/nfs4proc.c |    1 +
 1 file changed, 1 insertion(+)

diff --git i/fs/nfs/nfs4proc.c w/fs/nfs/nfs4proc.c
index 3d6730213f9d..30f6548f2b99 100644
--- i/fs/nfs/nfs4proc.c
+++ w/fs/nfs/nfs4proc.c
@@ -1771,6 +1771,7 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
 			nfs_setattr_update_inode(state->inode, sattr);
 		nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr);
 	}
+	nfs_revalidate_inode(server, state->inode);
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
 	*res = state;
-- 
