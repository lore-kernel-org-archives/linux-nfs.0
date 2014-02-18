Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f169.google.com ([209.85.214.169]:58112 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbaBRSgK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Feb 2014 13:36:10 -0500
Received: by mail-ob0-f169.google.com with SMTP id wo20so19161728obc.0
        for <linux-nfs@vger.kernel.org>; Tue, 18 Feb 2014 10:36:09 -0800 (PST)
Message-ID: <1392748566.4923.32.camel@leira.trondhjem.org>
Subject: Re: [PATCH 01/12] NFS fix error return in nfs4_select_rw_stateid
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: Neil Brown <neilb@suse.de>,
        linuxnfs Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 18 Feb 2014 13:36:06 -0500
In-Reply-To: <09F2502D-8D13-4129-BFF2-D5AF84FAB1DF@netapp.com>
References: <1392737765-41942-1-git-send-email-andros@netapp.com>
	 <1392741222.4923.4.camel@leira.trondhjem.org>
	 <09F2502D-8D13-4129-BFF2-D5AF84FAB1DF@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-02-18 at 17:56 +0000, Adamson, Andy wrote:
> On Feb 18, 2014, at 11:33 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > On Tue, 2014-02-18 at 10:36 -0500, andros@netapp.com wrote:
> >> From: Andy Adamson <andros@netapp.com>
> >> 
> >> Do not return an error when nfs4_copy_delegation_stateid succeeds.
> >> 
> >> Signed-off-by: Andy Adamson <andros@netapp.com>
> >> ---
> >> fs/nfs/nfs4state.c | 5 ++++-
> >> 1 file changed, 4 insertions(+), 1 deletion(-)
> >> 
> >> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> >> index ba18958..1cfde97 100644
> >> --- a/fs/nfs/nfs4state.c
> >> +++ b/fs/nfs/nfs4state.c
> >> @@ -1120,8 +1120,11 @@ int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
> >> 	if (ret == -EIO)
> >> 		/* A lost lock - don't even consider delegations */
> >> 		goto out;
> >> -	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
> >> +	/* returns true if delegation stateid found and copied */
> >> +	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode)) {
> >> +		ret = 0;
> >> 		goto out;
> >> +	}
> >> 	if (ret != -ENOENT)
> >> 		/* nfs4_copy_delegation_stateid() didn't over-write
> >> 		 * dst, so it still has the lock stateid which we now
> > 
> > Ouch! That looks like it would trigger looping in both the read and
> > write code when we're holding a delegation. Is that what you end up
> > seeing?
> 
> Actually, I saw it trying to run Anna’s intra server to server copy code.  In this case, the server side copy failed and normal READ/WRITE from the client then suceeded.  In that case I did not see any looping...
> 
> > 
> > It looks like it was introduced by commit ef1820f9be27b…
> 
> Yep. Should I include that commit in the comment?

I added a 'Fixes:' and 'Link:' to the patch before I applied it. I also
added a stable fix request for 3.12+...

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


