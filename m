Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22042 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156Ab2HNTLs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Aug 2012 15:11:48 -0400
Date: Tue, 14 Aug 2012 15:11:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        Richard Ems <richard.ems@cape-horn-eng.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs_lookup_revalidate BUG ?
Message-ID: <20120814151143.30fb9ca9@tlielax.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93A4DFC@SACEXCMBX04-PRD.hq.netapp.com>
References: <502A21A1.7020206@cape-horn-eng.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA93A4848@SACEXCMBX04-PRD.hq.netapp.com>
	<20120814183512.GI23464@ZenIV.linux.org.uk>
	<4FA345DA4F4AE44899BD2B03EEEC2FA93A4DFC@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 14 Aug 2012 18:48:35 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2012-08-14 at 19:35 +0100, Al Viro wrote:
> > On Tue, Aug 14, 2012 at 06:04:08PM +0000, Myklebust, Trond wrote:
> > > > Is this a known BUG ?
> > > > Which other information or test can I do to contribute searching/resolving this issue?
> > > 
> > > I'm not 100% certain, but it looks to me as if the call to dget_parent()
> > > in nfs_lookup_revalidate is returning NULL.
> > > 
> > > Could you please apply the following patch, and see if that triggers the
> > > WARN_ON instead of the above Oops?
> > 
> > Unlikely as hell.  dget_parent() has only one return in it, and it's
> >         BUG_ON(!ret->d_count);
> >         ret->d_count++;
> >         spin_unlock(&ret->d_lock);
> >         return ret;
> > so it's extremely unlikely that it would managed to return NULL.  Not
> > without oopsing...
> 
> Agreed, but the Oops is a NULL pointer dereference of offset 00038,
> which looks suspiciously like a deference of (struct dentry)->d_inode.
> There are only 2 of those in the vicinity of nfs_lookup_revalidate+0x2d:
> one is a dereference of parent->d_inode, the other is dentry->d_inode...
> 

One way to determine this would be to follow the instructions here,
substituting nfs.ko for cifs.ko:

    http://wiki.samba.org/index.php/LinuxCIFS_troubleshooting#Oopses

...and see if you can get a listing of the spot where it oopsed. You
may need kernel debuginfo installed if you're using a distro kernel
though.

[1]: yes, I know that page is about CIFS troubleshooting, but that
method should work for nfs.ko too.

-- 
Jeff Layton <jlayton@redhat.com>
