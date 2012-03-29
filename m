Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55706 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932696Ab2C2CKe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 22:10:34 -0400
Received: by iagz16 with SMTP id z16so2320093iag.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2012 19:10:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332979882.19172.38.camel@lade.trondhjem.org>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
	<38AF6CFC-8017-4D08-8DB0-A80BA724E54A@netapp.com>
	<1332947296.11400.7.camel@lade.trondhjem.org>
	<74BCDDD5-955E-4C06-9640-47D477A9FF8F@netapp.com>
	<CAKYAXd-eWRrja8bGqS7tTWehPNgAM4gtPALfAexRvTwkbbBOGw@mail.gmail.com>
	<1332979882.19172.38.camel@lade.trondhjem.org>
Date: Thu, 29 Mar 2012 11:10:33 +0900
Message-ID: <CAKYAXd9eyN49AvWjD8ik6-mCB_KO7EiHKiSD=J-CPFxDeZ8fWQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] NFSv4: Fix two infinite loops in the mount code
From: Namjae Jeon <linkinjeon@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi. Trond.

First sorry for noise.

if goto is encountered by branch predictor with switch condition, CPU
try to fetch instruction code after label to cpu cache.
And Cpu is idiling and CPU clock is watsted. if branch prediction is
fail, this cost is more big.
but this patch is good as I said before.

Thanks.

2012/3/29 Myklebust, Trond <Trond.Myklebust@netapp.com>:
> On Thu, 2012-03-29 at 08:55 +0900, Namjae Jeon wrote:
>> Hi. Trond.
>>
>> Normally goto statement is not recommended(pipeline and branch
>> prediction) it is only recommended as a last resort if there is no
>> method to escape this loop.
>
> ????????????? A goto is an unconditional branch; there is no further
> branch prediction involved once once the processor gets the value of
> 'err' in that switch statement correct. Exactly how would adding an
> extra set+test of exception.retry after the switch() help the branch
> predictor in this situation?
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
