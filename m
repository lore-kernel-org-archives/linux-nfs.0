Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:60362 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432Ab2FZL5c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2012 07:57:32 -0400
MIME-Version: 1.0
In-Reply-To: <20120626111024.GB14279@fieldses.org>
References: <1340448406-10161-1-git-send-email-linkinjeon@gmail.com>
	<02B16139-AFD6-4F06-99C0-C406B1A7E1DC@netapp.com>
	<FE90D2E0-C4C9-44BC-829F-ABE94801AB4C@netapp.com>
	<20120623155710.GA10787@fieldses.org>
	<20120623160923.GB10787@fieldses.org>
	<CAKYAXd80v10car7awm3Y5bzk_nXLj8NLi7C8PxUW15L9-S7pEw@mail.gmail.com>
	<20120625113025.GB16920@fieldses.org>
	<CAKYAXd-h5FPZUDwvJdbXXeQtXjUqQE5s9e1CvuOdpQWgqzG8kw@mail.gmail.com>
	<20120626111024.GB14279@fieldses.org>
Date: Tue, 26 Jun 2012 20:57:30 +0900
Message-ID: <CAKYAXd9-ubxP8iQqTWTG-34Vb_yrDU=9f9hsiRk4go_=QDfxmg@mail.gmail.com>
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

2012/6/26, Fields James <bfields@fieldses.org>:
> On Tue, Jun 26, 2012 at 02:51:52PM +0900, Namjae Jeon wrote:
>> 2012/6/25, Fields James <bfields@fieldses.org>:
>> > On Sun, Jun 24, 2012 at 02:12:49PM +0900, Namjae Jeon wrote:
>> >> 2012/6/24, Fields James <bfields@fieldses.org>:
>> >> > On Sat, Jun 23, 2012 at 11:57:10AM -0400, Fields James wrote:
>> >> >> On Sat, Jun 23, 2012 at 03:52:20PM +0000, Myklebust, Trond wrote:
>> >> >> > The other objection is that NFSv3 already has a way to do this
>> >> >> > via
>> >> >> > the
>> >> >> > MOUNT protocol. We already call MOUNTPROC3_UMNT/MOUNTPROC_UMNT on
>> >> >> > unmount of a filesystem.
>> >> >> >
>> >> >> > The problem with this approach is that if the NFS client crashes
>> >> >> > before
>> >> >> > it can call this function, then the server never gets notified.
>> >> >> > That
>> >> >> > is
>> >> >> > a problem that your patch has too...
>> >> >>
>> >> >> Yes.  Could you instead work on describing *exactly* what the
>> >> >> original
>> >> >> problem was that prompted this?
>> >> >
>> >> > ("You" here meaning Namjae Jeon, of course).
>> >> >
>> >> > And note here we've all read the changelog, that's not what I'm
>> >> > asking
>> >> > for.
>> >> >
>> >> > I want to know the details of *your* specific case.  "I have X
>> >> > clients
>> >> > that I use for Y, periodically I want to unmount the exported
>> >> > filesystem
>> >> > to do Z, I tried doing W but it didn't work...".
>> >> As you remember, We discussed this
>> >> issue(http://www.spinics.net/lists/linux-nfs/msg29997.html) with you
>> >> before. you guided me to use exportfs -f call on nfs server.
>> >> It is hard to use this method on our system
>> >
>> > Why is it hard?
>> Two target are connected by only nfs.. we can't manually hand exportfs
>> -f..
>
> So how can you call umount?
I am currently checking two approaches.
1. Add flush cache code in current MOUNTPROC3_UMNT/MOUNTPROC_UMNT.
 -> I heard from Trond that there already are
MOUNTPROC3_UMNT/MOUNTPROC_UMNT. So I will try to fix this issue on
current protocols without many changes. It is not specification
violation.
2. Check your suggestion.
-> I think that your suggestion is very good. it will cover device
unplug case(automount will try to umount about unplugged device) and
current busy umount issue.
If I have one concern, It need to change VFS code. I need your review
and Ack to commit if I post this patch.

Thanks.
>
> --b.
>
