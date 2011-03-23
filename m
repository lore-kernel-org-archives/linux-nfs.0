Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from os.inf.tu-dresden.de ([141.76.48.99]:47928 "EHLO
	os.inf.tu-dresden.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab1CWWaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 18:30:21 -0400
Date: Wed, 23 Mar 2011 23:30:17 +0100
From: Adam Lackorzynski <adam@os.inf.tu-dresden.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 2.6.38: Quota over NFS4
Message-ID: <20110323223017.GA5177@os.inf.tu-dresden.de>
References: <20110320172758.GK11929@os.inf.tu-dresden.de>
 <20110320212633.GA26036@fieldses.org>
 <20110320213111.GO11929@os.inf.tu-dresden.de>
 <20110320214316.GB26036@fieldses.org>
 <20110321184043.GC4992@os.inf.tu-dresden.de>
 <20110321222301.GB472@fieldses.org>
 <20110322221305.GA5857@os.inf.tu-dresden.de>
 <20110323150328.GD23418@fieldses.org>
 <20110323174052.GE5005@os.inf.tu-dresden.de>
 <20110323190632.GA26306@fieldses.org>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20110323190632.GA26306@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Wed Mar 23, 2011 at 15:06:32 -0400, J. Bruce Fields wrote:
> On Wed, Mar 23, 2011 at 06:40:52PM +0100, Adam Lackorzynski wrote:
> > > On Tue, Mar 22, 2011 at 11:13:06PM +0100, Adam Lackorzynski wrote:
> > > > 
> > > > On Mon Mar 21, 2011 at 18:23:01 -0400, J. Bruce Fields wrote:
> > > > > 
> > > > > Oh, right, you'd want to unmount on the sender before copying.
> > > > > 
> > > > > You *may* still get some kind of usable result if you fsck the fs you
> > > > > get on the receiver, but who knows.
> > > > 
> > > > Ok, good news. After some fight I got it mounted in the VM. Reproducible
> > > > with the original 2.6.38 kernel (as released) and also reproducible with
> > > > latest git as of today. What now?
> > > 
> > > OK, so now you can reproduce the problem on one xfs filesystem, but not
> > > the other.
> > > 
> > > Can we find any differences between the two filesystems?  Was one
> > > created with different features, for example?
> > >
> > > Might also be worth asking xfs developers for ideas.
> > 
> > Bisecting shows this commit:
> 
> That's an odd place for it to end up.  You're positive the problem is
> reliably reproduceable after this commit and not in the commit
> immediately previous?

I probably mistyped something and thus bisected again:

acfdf5c383b38f7f4dddae41b97c97f1ae058f49 is the first bad commit
commit acfdf5c383b38f7f4dddae41b97c97f1ae058f49
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Jan 31 19:20:39 2011 -0500

    nfsd4: acquire only one lease per file
    
    Instead of acquiring one lease each time another client opens a file,
    nfsd can acquire just one lease to represent all of them, and reference
    count it to determine when to release it.
    
    This fixes a regression introduced by
    c45821d263a8a5109d69a9e8942b8d65bcd5f31a "locks: eliminate fl_mylease
    callback": after that patch, only the struct file * is used to determine
    who owns a given lease.  But since we recently converted the server to
    share a single struct file per open, if we acquire multiple leases on
    the same file from nfsd, it then becomes impossible on unlocking a lease
    to determine which of those leases (all of whom share the same struct
    file *) we meant to remove.
    
    Thanks to Takashi Iwai <tiwai@suse.de> for catching a bug in a previous
    version of this patch.
    
    Tested-by: Takashi Iwai <tiwai@suse.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

:040000 040000 5bf94b91c7c696586f0aaf8b5df1cd9c4aa70ac0 4ee1f39f455ee7f648fccedc1ddba4da6a94cec7 M      fs

 


Adam
-- 
Adam                 adam@os.inf.tu-dresden.de
  Lackorzynski         http://os.inf.tu-dresden.de/~adam/
