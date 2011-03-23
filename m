Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49031 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756158Ab1CWTGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 15:06:33 -0400
Date: Wed, 23 Mar 2011 15:06:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Adam Lackorzynski <adam@os.inf.tu-dresden.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 2.6.38: Quota over NFS4
Message-ID: <20110323190632.GA26306@fieldses.org>
References: <20110317230315.GG31845@fieldses.org>
 <20110320172758.GK11929@os.inf.tu-dresden.de>
 <20110320212633.GA26036@fieldses.org>
 <20110320213111.GO11929@os.inf.tu-dresden.de>
 <20110320214316.GB26036@fieldses.org>
 <20110321184043.GC4992@os.inf.tu-dresden.de>
 <20110321222301.GB472@fieldses.org>
 <20110322221305.GA5857@os.inf.tu-dresden.de>
 <20110323150328.GD23418@fieldses.org>
 <20110323174052.GE5005@os.inf.tu-dresden.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110323174052.GE5005@os.inf.tu-dresden.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 23, 2011 at 06:40:52PM +0100, Adam Lackorzynski wrote:
> Hi,
> 
> On Wed Mar 23, 2011 at 11:03:28 -0400, J. Bruce Fields wrote:
> > (How'd linux-nfs get dropped off the cc:?)
> 
> I must have accidently done single reply only, sorry.

OK, assuming you won't mind my re-adding it.

> 
> > On Tue, Mar 22, 2011 at 11:13:06PM +0100, Adam Lackorzynski wrote:
> > > 
> > > On Mon Mar 21, 2011 at 18:23:01 -0400, J. Bruce Fields wrote:
> > > > 
> > > > Oh, right, you'd want to unmount on the sender before copying.
> > > > 
> > > > You *may* still get some kind of usable result if you fsck the fs you
> > > > get on the receiver, but who knows.
> > > 
> > > Ok, good news. After some fight I got it mounted in the VM. Reproducible
> > > with the original 2.6.38 kernel (as released) and also reproducible with
> > > latest git as of today. What now?
> > 
> > OK, so now you can reproduce the problem on one xfs filesystem, but not
> > the other.
> > 
> > Can we find any differences between the two filesystems?  Was one
> > created with different features, for example?
> >
> > Might also be worth asking xfs developers for ideas.
> 
> Bisecting shows this commit:

That's an odd place for it to end up.  You're positive the problem is
reliably reproduceable after this commit and not in the commit
immediately previous?

--b.

> 5d926e8c2f46dc09f4ddde86644a5f1d0726a470 is the first bad commit
> commit 5d926e8c2f46dc09f4ddde86644a5f1d0726a470
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Mon Feb 7 16:53:46 2011 -0500
> 
>     nfsd4: modify fi_delegations under recall_lock
>     
>     Modify fi_delegations only under the recall_lock, allowing us to use
>     that list on lease breaks.
>     
>     Also some trivial cleanup to simplify later changes.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> :040000 040000 fa71771d862119d1918c40a0ea25815f2f8b16bf 5bf94b91c7c696586f0aaf8b5df1cd9c4aa70ac0 M      fs
> 
> 
> Adam
> -- 
> Adam                 adam@os.inf.tu-dresden.de
>   Lackorzynski         http://os.inf.tu-dresden.de/~adam/
