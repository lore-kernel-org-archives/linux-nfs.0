Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37071 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751937Ab3JUSBE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 14:01:04 -0400
Date: Mon, 21 Oct 2013 14:01:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Tony Asleson <tasleson@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: Add -s option.
Message-ID: <20131021180103.GF18657@fieldses.org>
References: <1380734389-8202-1-git-send-email-tasleson@redhat.com>
 <20131002214015.GA20902@fieldses.org>
 <5265315D.9030008@RedHat.com>
 <20131021140114.GE18657@fieldses.org>
 <52655C68.1000604@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52655C68.1000604@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 21, 2013 at 12:55:04PM -0400, Steve Dickson wrote:
> 
> 
> On 21/10/13 10:01, J. Bruce Fields wrote:
> > On Mon, Oct 21, 2013 at 09:51:25AM -0400, Steve Dickson wrote:
> >> I guess we could change -v to used what the -s is proposing,
> >> but that could break someone's existing configuration...  
> > 
> > Also, looking at my home server....  It would be annoying to get:
> > 
> > 	/export *(rw,sync,wdelay,hide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)
> > 
> > when all you need is:
> > 
> > 	/export <world>(rw,wdelay,insecure,no_root_squash,no_subtree_check)
> > 
> > (Actually I wonder why it's even showing wdelay and no_subtree_check
> > when those are both defaults?  But this is on F16, maybe it's different
> > now.  I should really update that machine.)
> No, the defaults have not changed for (quite) a while... 
> The defaults are: 
>     ro, root_squash, wdelay, no_subtree_check
> 
> Now it turns out wdelay (aka NFSEXP_GATHERED_WRITES) is a v2 only thing... 
> So do we really need to have that on by default, now that we are 
> slowly moving away from v2 support?

Yeah, it should stay on by default.

Anyway it wasn't the defaults I was wondering about so much as why
exportfs -v was printing out some options that were already set at their
defaults.

I guess that stuff is just hardwired into
utils/exportfs/exportfs.c:dump().  So we may want the following.

(Anyway, ACK to the -s patch.)

--b.

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 4331697..0cde3e9 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -665,7 +665,7 @@ dump(int verbose)
 				c = dumpopt(c, "rw");
 			if (ep->e_flags & NFSEXP_ASYNC)
 				c = dumpopt(c, "async");
-			if (ep->e_flags & NFSEXP_GATHERED_WRITES)
+			if (!(ep->e_flags & NFSEXP_GATHERED_WRITES))
 				c = dumpopt(c, "wdelay");
 			if (ep->e_flags & NFSEXP_NOHIDE)
 				c = dumpopt(c, "nohide");
@@ -679,7 +679,7 @@ dump(int verbose)
 				c = dumpopt(c, "no_root_squash");
 			if (ep->e_flags & NFSEXP_ALLSQUASH)
 				c = dumpopt(c, "all_squash");
-			if (ep->e_flags & NFSEXP_NOSUBTREECHECK)
+			if (!(ep->e_flags & NFSEXP_NOSUBTREECHECK))
 				c = dumpopt(c, "no_subtree_check");
 			if (ep->e_flags & NFSEXP_NOAUTHNLM)
 				c = dumpopt(c, "insecure_locks");
