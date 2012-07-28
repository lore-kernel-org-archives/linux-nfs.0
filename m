Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:34564 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab2G1EwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jul 2012 00:52:11 -0400
MIME-Version: 1.0
In-Reply-To: <20120724162420.GG8570@fieldses.org>
References: <1341717459-7297-1-git-send-email-linkinjeon@gmail.com>
	<20120710145937.GA1947@fieldses.org>
	<CAKYAXd97ir=tvxWTC4eVmrrXBEpK=XCX3-e8XUjCPy16eHoibQ@mail.gmail.com>
	<20120711140944.GB11432@fieldses.org>
	<CAKYAXd__BLFPOw=+tt=cqZgyM45y5mSOTamVaFTU26BNSNa=2A@mail.gmail.com>
	<CAKYAXd9KLxDqXSqgk7Y1rNv9cw-r+PHPSenQCnkRh9_0_6HmAQ@mail.gmail.com>
	<20120724162420.GG8570@fieldses.org>
Date: Sat, 28 Jul 2012 13:52:10 +0900
Message-ID: <CAKYAXd9yu7iC=acJJEO_rN905JRdmVMUqJyFAtbVWjh2o+u6vw@mail.gmail.com>
Subject: Re: [PATCH] nfs-util: Add cache_flush in mountd UMNT procedure.
From: Namjae Jeon <linkinjeon@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: SteveD@redhat.com, Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Vivek Trivedi <vtrivedi018@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> Hi James.
>> I have a question.
>> If we found the method to notify nfs when unplugging device,
>
Hi James.
> What's that?
I need to check more...

>
>> Can nfsd
>> flush only entry of usb mount ?
>
> Hm, I don't think there's anything that does that now.  But I think if
> you look it up and set the cache item's expiry_time to the current unix
> time in seconds, that'd be at least a start.
>
> Come to think of it you should actually be able to do that from
> userspace if you want: just write a negative cache entry for that
> export.
>
> However you do this there may still be some brief delay while some
> thread finishes processing an rpc using the entry; I don't know what to
> do about that.  It's unlikely in your case (where clients have unmounted
> first).
Okay, I will look for more.
Thanks for your reply.
>
> --b.
>
