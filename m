Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:37821 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501Ab2FZFvy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2012 01:51:54 -0400
MIME-Version: 1.0
In-Reply-To: <20120625113025.GB16920@fieldses.org>
References: <1340448406-10161-1-git-send-email-linkinjeon@gmail.com>
	<02B16139-AFD6-4F06-99C0-C406B1A7E1DC@netapp.com>
	<FE90D2E0-C4C9-44BC-829F-ABE94801AB4C@netapp.com>
	<20120623155710.GA10787@fieldses.org>
	<20120623160923.GB10787@fieldses.org>
	<CAKYAXd80v10car7awm3Y5bzk_nXLj8NLi7C8PxUW15L9-S7pEw@mail.gmail.com>
	<20120625113025.GB16920@fieldses.org>
Date: Tue, 26 Jun 2012 14:51:52 +0900
Message-ID: <CAKYAXd-h5FPZUDwvJdbXXeQtXjUqQE5s9e1CvuOdpQWgqzG8kw@mail.gmail.com>
Subject: Re: [RFC PATCH] nfs: Add NFS3PROC_UMOUNT procedure.
From: Namjae Jeon <linkinjeon@gmail.com>
To: Fields James <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Morton Andrew <akpm@linux-foundation.org>,
        Harrosh Boaz <bharrosh@panasas.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>,
        Vivek Trivedi <t.vivek@samsung.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/6/25, Fields James <bfields@fieldses.org>:
> On Sun, Jun 24, 2012 at 02:12:49PM +0900, Namjae Jeon wrote:
>> 2012/6/24, Fields James <bfields@fieldses.org>:
>> > On Sat, Jun 23, 2012 at 11:57:10AM -0400, Fields James wrote:
>> >> On Sat, Jun 23, 2012 at 03:52:20PM +0000, Myklebust, Trond wrote:
>> >> > The other objection is that NFSv3 already has a way to do this via
>> >> > the
>> >> > MOUNT protocol. We already call MOUNTPROC3_UMNT/MOUNTPROC_UMNT on
>> >> > unmount of a filesystem.
>> >> >
>> >> > The problem with this approach is that if the NFS client crashes
>> >> > before
>> >> > it can call this function, then the server never gets notified. That
>> >> > is
>> >> > a problem that your patch has too...
>> >>
>> >> Yes.  Could you instead work on describing *exactly* what the original
>> >> problem was that prompted this?
>> >
>> > ("You" here meaning Namjae Jeon, of course).
>> >
>> > And note here we've all read the changelog, that's not what I'm asking
>> > for.
>> >
>> > I want to know the details of *your* specific case.  "I have X clients
>> > that I use for Y, periodically I want to unmount the exported
>> > filesystem
>> > to do Z, I tried doing W but it didn't work...".
>> As you remember, We discussed this
>> issue(http://www.spinics.net/lists/linux-nfs/msg29997.html) with you
>> before. you guided me to use exportfs -f call on nfs server.
>> It is hard to use this method on our system
>
> Why is it hard?
Two target are connected by only nfs.. we can't manually hand exportfs -f..
And I should make each new App on client / server to call exportfs -f.
>
> Could you hack umount to do the equivalent of "exportfs -f" before
> calling the umount?
Good Idea! I will check your suggestion.

>
>> and nomally the user is
>> thinking it is problem device busy happen after umounting.
>>
>> The details of specific case.
>> 1. There are two target or two PC. and Client want to access files of
>> usb device on server.
>> 2. the client try to mount usb mount point using nfs on sever after
>> plugging usb device.
>> 3. we try to umount mount point directory on client.
>> 4. and when we try to umount usb device mount directory server, device
>> busy message occured like this (umount: can't umount /mnt: Device or
>> resource busy)
>
> Right, so I don't think you want protocol modifications.  They take a
> few years to get hammered out and then make it into implementations, and
> they won't help a great deal with your problem anyway.  (Because of
> problems like the possibility of lost "unmount" calls that Trond
> mentions.)
>
> Either modify umount itself to flush the export cache before attempting
> the unmount, or if that doesn't work perhaps you could patch the kernel
> to notify nfsd on unmount and let it attemt to clear its caches before
> deciding whether the filesystem is busy.
After checking your suggestion I will share with you.
Thanks a lot. James.
>
> --b.
>
