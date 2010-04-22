From: "J.Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] - avoid permission checks on EXCLUSIVE_CREATE replay
Date: Thu, 22 Apr 2010 17:18:01 -0400
Message-ID: <20100422211801.GF10302@fieldses.org>
References: <20100422101042.226f71d6@notabene.brown> <20100422162533.GH5926@fieldses.org> <20100423071631.27ff3a5a@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60777 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758837Ab0DVVSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 17:18:04 -0400
In-Reply-To: <20100423071631.27ff3a5a-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 23, 2010 at 07:16:31AM +1000, Neil Brown wrote:
> On Thu, 22 Apr 2010 12:25:33 -0400
> "J.Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Thu, Apr 22, 2010 at 10:10:42AM +1000, Neil Brown wrote:
> > > 
> > > With NFSv4, if we create a file then open it we explicit avoid checking the
> > > permissions on the file during the open because the fact that we created it
> > > ensures we should be allow to open it (the create and the open should appear
> > > to be a single operation).
> > > 
> > > However if the reply to an EXCLUSIVE create gets lots and the client resends
> > > the create, the current code will perform the permission check - because it
> > > doesn't realise that it did the open already..
> > > 
> > > This patch should fix this.
> > 
> > Thanks, but: hm, does this leave a loophole for a clever attacker?
> > They'll still have to get past the initial
> > 
> > 	fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE)
> > 
> > but that just checks the parent directory; if the existing file is
> > actually owned by someone else, do we allow an open that we shouldn't?
> > 
> > Maybe when "created" is set we should keep the permission check but add
> > NFSD_ALLOW_OWNER_OVERRIDE?
> > 
> 
> I think that is possibly a good idea.  However......
> 
> commit 81ac95c5569d7a60ab5db6c1ccec56c12b3ebcb5
> Author: J. Bruce Fields <bfields@fieldses.org>
> Date:   Wed Nov 8 17:44:40 2006 -0800
> 
>     [PATCH] nfsd4: fix open-create permissions
>     
>     In the case where an open creates the file, we shouldn't be rechecking
>     permissions to open the file; the open succeeds regardless of what the new
>     file's mode bits say.
>     
>     This patch fixes the problem, but only by introducing yet another parameter
>     to nfsd_create_v3.  This is ugly.  This will be fixed by later patches.
>     
> 
> I wouldn't want to get in the way of these 'later patches' that might be
> going to remove the 'created' flag from nfsd_create_v3 :-)

Har.  I was optimistic.

That code *is* really hairy.  I'll take another look.

--b.
