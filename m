Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:32854 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758816Ab0DVVQj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 17:16:39 -0400
Date: Fri, 23 Apr 2010 07:16:31 +1000
From: Neil Brown <neilb@suse.de>
To: "J.Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] - avoid permission checks on EXCLUSIVE_CREATE replay
Message-ID: <20100423071631.27ff3a5a@notabene.brown>
In-Reply-To: <20100422162533.GH5926@fieldses.org>
References: <20100422101042.226f71d6@notabene.brown>
	<20100422162533.GH5926@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 22 Apr 2010 12:25:33 -0400
"J.Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Apr 22, 2010 at 10:10:42AM +1000, Neil Brown wrote:
> > 
> > With NFSv4, if we create a file then open it we explicit avoid checking the
> > permissions on the file during the open because the fact that we created it
> > ensures we should be allow to open it (the create and the open should appear
> > to be a single operation).
> > 
> > However if the reply to an EXCLUSIVE create gets lots and the client resends
> > the create, the current code will perform the permission check - because it
> > doesn't realise that it did the open already..
> > 
> > This patch should fix this.
> 
> Thanks, but: hm, does this leave a loophole for a clever attacker?
> They'll still have to get past the initial
> 
> 	fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE)
> 
> but that just checks the parent directory; if the existing file is
> actually owned by someone else, do we allow an open that we shouldn't?
> 
> Maybe when "created" is set we should keep the permission check but add
> NFSD_ALLOW_OWNER_OVERRIDE?
> 

I think that is possibly a good idea.  However......

commit 81ac95c5569d7a60ab5db6c1ccec56c12b3ebcb5
Author: J. Bruce Fields <bfields@fieldses.org>
Date:   Wed Nov 8 17:44:40 2006 -0800

    [PATCH] nfsd4: fix open-create permissions
    
    In the case where an open creates the file, we shouldn't be rechecking
    permissions to open the file; the open succeeds regardless of what the new
    file's mode bits say.
    
    This patch fixes the problem, but only by introducing yet another parameter
    to nfsd_create_v3.  This is ugly.  This will be fixed by later patches.
    

I wouldn't want to get in the way of these 'later patches' that might be
going to remove the 'created' flag from nfsd_create_v3 :-)

NeilBrown
