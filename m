Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43184 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab2GXQYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jul 2012 12:24:24 -0400
Date: Tue, 24 Jul 2012 12:24:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: SteveD@redhat.com, Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Vivek Trivedi <vtrivedi018@gmail.com>
Subject: Re: [PATCH] nfs-util: Add cache_flush in mountd UMNT procedure.
Message-ID: <20120724162420.GG8570@fieldses.org>
References: <1341717459-7297-1-git-send-email-linkinjeon@gmail.com>
 <20120710145937.GA1947@fieldses.org>
 <CAKYAXd97ir=tvxWTC4eVmrrXBEpK=XCX3-e8XUjCPy16eHoibQ@mail.gmail.com>
 <20120711140944.GB11432@fieldses.org>
 <CAKYAXd__BLFPOw=+tt=cqZgyM45y5mSOTamVaFTU26BNSNa=2A@mail.gmail.com>
 <CAKYAXd9KLxDqXSqgk7Y1rNv9cw-r+PHPSenQCnkRh9_0_6HmAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKYAXd9KLxDqXSqgk7Y1rNv9cw-r+PHPSenQCnkRh9_0_6HmAQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 12, 2012 at 07:43:49AM +0900, Namjae Jeon wrote:
> 2012/7/12, Namjae Jeon <linkinjeon@gmail.com>:
> > 2012/7/11, J. Bruce Fields <bfields@fieldses.org>:
> >> On Wed, Jul 11, 2012 at 01:10:53PM +0900, Namjae Jeon wrote:
> >>> 2012/7/10, J. Bruce Fields <bfields@fieldses.org>:
> >>> > On Sat, Jul 07, 2012 at 11:17:39PM -0400, Namjae Jeon wrote:
> >>> >> For removing storage device - user needs to safely un-mount the
> >>> >> device
> >>> >> and then eject. But if 'EBUSY' occurs in umount then it will create
> >>> >> confusion for the user as it will mean some I/O is in progress - and
> >>> >> won't allow user to safely ejecting device.
> >>> >
> >>> Hi James.
> >>> > The one drawback is that recovering from the cache flushes might be a
> >>> > little expensive if you have a lot of exports in use.
> >>> Good point. I will look for more there is the method flush only mount
> >>> entry.
> >>
> >> I don't think there's a good way to flush only one entry.
> >>
> >> Also, this isn't going to help for NFSv4 since a v4 client won't do an
> >> unmount call.
> > Okay.
> >>
> >>> > I'm curious, since you said this was for a usb disk: are users
> >>> > expected
> >>> > to just unplug it (in which case--is it read only?) or do they have
> >>> > some
> >>> > way of unmounting before they pull the plug?
> >>> Users expected to unplug it on both read only and read/write.
> >>> And there is no way that system be prepared to know about the
> >>> intelligence when the user is going to unplug.
> >>> if the user really want to detach the device safely. There is an
> >>> option like the desktop PC - where, we can say - umount/eject the
> >>> device. There is a proper user interface for safe removal.
> >>> but they can not unplug safely if usb device is mounted with nfs
> >>> because of this issue.
> >>
> >> Ideal might be to get some way to notify nfsd when the device
> >> diseappears or the filesystem wants to unmount.  I don't know how to do
> >> that.
> > Okay. I will look for good solution for this issue.
> > Thanks.
> Hi James.
> I have a question.
> If we found the method to notify nfs when unplugging device,

What's that?

> Can nfsd
> flush only entry of usb mount ?

Hm, I don't think there's anything that does that now.  But I think if
you look it up and set the cache item's expiry_time to the current unix
time in seconds, that'd be at least a start.

Come to think of it you should actually be able to do that from
userspace if you want: just write a negative cache entry for that
export.

However you do this there may still be some brief delay while some
thread finishes processing an rpc using the entry; I don't know what to
do about that.  It's unlikely in your case (where clients have unmounted
first).

--b.
