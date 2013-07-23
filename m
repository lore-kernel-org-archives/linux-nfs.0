Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f181.google.com ([209.85.192.181]:55632 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933220Ab3GWRaY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jul 2013 13:30:24 -0400
Received: by mail-pd0-f181.google.com with SMTP id 14so8412854pdj.12
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jul 2013 10:30:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374598847.12943.0.camel@leira.trondhjem.org>
References: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com>
	<1374098347-30196-2-git-send-email-Trond.Myklebust@netapp.com>
	<CAHsu+b-b=-pQ4f8AfHHDaPpAK3YvHomS3X-QuEJkzbAsuJBYfg@mail.gmail.com>
	<1374598847.12943.0.camel@leira.trondhjem.org>
Date: Tue, 23 Jul 2013 19:30:23 +0200
Message-ID: <CAHsu+b--M3FqF21o=0jz8DoiROy89FVi5oZ0Tbn8zV2CG63oBQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFSv4: encode_attrs should not backfill the bitmap
 and attribute length
From: Andre Heider <a.heider@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Rick Macklem <rmacklem@uoguelph.ca>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 23, 2013 at 7:00 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Tue, 2013-07-23 at 17:59 +0200, Andre Heider wrote:
>> Trond,
>>
>> On Wed, Jul 17, 2013 at 11:59 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > The attribute length is already calculated in advance. There is no
>> > reason why we cannot calculate the bitmap in advance too so that
>> > we don't have to play pointer games.
>>
>> I'm sorry to report that this patch seems to be more than just a cleanup.
>>
>> I just tested 3.11-rc2 against my FreeBSD server, and with just patch
>> 1/2 (as in -rc2) I still get the failure upon `touch`. It fails with
>> or without Rick's server patch.
>>
>> Applying this one on top of -rc2 fixes it.
>
> How about the attached instead of the cleanup?

Much better ;) Thanks again for the quick fix!

Feel free to add:
Tested-by: Andre Heider <a.heider@gmail.com>
