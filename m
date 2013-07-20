Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42523 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713Ab3GTIsk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Jul 2013 04:48:40 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so5298820pbb.33
        for <linux-nfs@vger.kernel.org>; Sat, 20 Jul 2013 01:48:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1774242197.1390191.1374190255822.JavaMail.root@uoguelph.ca>
References: <CAHsu+b_FuHaa9LG1vRv1d5LwA5Ue_Ss2eoJsKEC5dx-rnuApOg@mail.gmail.com>
	<1774242197.1390191.1374190255822.JavaMail.root@uoguelph.ca>
Date: Sat, 20 Jul 2013 10:48:39 +0200
Message-ID: <CAHsu+b84+RrqrZkEXjdd3-xCp0Cvs=U_e4mQHeuRyd+huUWwrA@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix a regression against the FreeBSD server
From: Andre Heider <a.heider@gmail.com>
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 19, 2013 at 1:30 AM, Rick Macklem <rmacklem@uoguelph.ca> wrote:
> Andre Heider wrote:
>> On Wed, Jul 17, 2013 at 11:59 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > Technically, the Linux client is allowed by the NFSv4 spec to send
>> > 3 word bitmaps as part of an OPEN request. However, this causes the
>> > current FreeBSD server to return NFS4ERR_ATTRNOTSUPP errors.
>> >
>> > Fix the regression by making the Linux client use a 2 word bitmap
>> > unless
>> > doing NFSv4.2 with labeled NFS.
>> >
>> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>
>> Tested-by: Andre Heider <a.heider@gmail.com>
>>
> I've attached the patch I plan to commit to FreeBSD's head soon, which
> fixes the server so that it checks for the high order bitmaps words
> being non-zero before replying with NFS4_ERR_ATTRNOTSUPP.
>
> The patch is pretty straightforward, but if you can apply it to your
> server and test it against the unpatched Linux client, that would be
> appreciated.

Confirmed, reverting the client patches and applying this server patch
also works ;)

Thanks,
Andre
