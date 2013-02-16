Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:42829 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792Ab3BPFRr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Feb 2013 00:17:47 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: V4 unmount causes a GETATTR
Date: Sat, 16 Feb 2013 05:17:45 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91F3DA928@sacexcmbx05-prd.hq.netapp.com>
References: <511E5838.2020103@RedHat.com>
 <20130215182531.GB19923@fieldses.org> <511EAC8B.3050403@RedHat.com>
In-Reply-To: <511EAC8B.3050403@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Steve Dickson
> Sent: Friday, February 15, 2013 4:46 PM
> To: J. Bruce Fields
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: V4 unmount causes a GETATTR
> 
> 
> 
> On 15/02/13 13:25, J. Bruce Fields wrote:
> > On Fri, Feb 15, 2013 at 10:46:00AM -0500, Steve Dickson wrote:
> >> Hello,
> >>
> >> I have not tracked down as to the exact reason, but it appears umount
> >> of v4 file system cause the directory to be revalidating causing the
> >> GETATTR.
> >>
> >> Is this revalidation really necessary on an unmount?
> >
> > I don't know, maybe not.  But even if it's not, there are other things
> > (like cleaning up state) that the client will likely try to do on
> > unmount.  In the presence of delegations it could have dirty data that
> > it's required to write back even if applications don't currently hold
> > any open files.
> Understood with dirty data... but what I as seeing was a v4 mount and then a
> reboot with no activity on the mount point...
> 
> >
> > So I don't think we can promise umount will work without the network.
> Again with open files (aka activity on the mount point) I agree but with no
> activity or open files, I'm think that GETATTR is simply not necessary...

You'd need to add a lookup intent specifically for umount. Otherwise the filesystem will not be able distinguish between path lookups for umount and other activity.

Also note that "no activity or open files" is no guarantee that you won't be holding delegations or pNFS layouts to return; you may still see hangs.

Cheers,
  Trond
