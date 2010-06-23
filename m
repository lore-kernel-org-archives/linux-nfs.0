Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36150 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab0FWROa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 13:14:30 -0400
Received: by vws9 with SMTP id 9so1205165vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jun 2010 10:14:29 -0700 (PDT)
In-Reply-To: <4C21AE7F.9080103@panasas.com>
References: <AANLkTilWpNghO37nF9Cmu3F7SxcHU2AI8hKyeDvNSi8d@mail.gmail.com>
	<4C21AE7F.9080103@panasas.com>
From: Yudong Gao <stgyd@umich.edu>
Date: Wed, 23 Jun 2010 10:14:09 -0700
Message-ID: <AANLkTimvyf-KbN-XWkawxp3SHG_WgHJ_sBXnlJjWMIjM@mail.gmail.com>
Subject: Re: Supported cluster file system in v4.1
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Benny,

Thanks a lot for the reply! I will check exofs.

We are looking for a block-based cluster file system that can be
deployed on top of a cluster of commodity machines and can use the
machines' local storage instead of using a SAN. We find that OCFS2 is
a good candidate. Is it possible to use OCFS2 as the storage server in
pNFS?

Thanks a lot!

best,

Yudong

On Tue, Jun 22, 2010 at 11:49 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> On 2010-06-16 20:17, Yudong Gao wrote:
>> Hi,
>>
>> We are trying to setup a pNFS testbed and deploy a cluster file system
>> on the storage servers. We find that the GFS from RedHat supports
>> pNFS. But is there any other cluster file system that also supports
>> pNFS?
>
> Yudong, what are you looking for in your tests?
> Another option for the pNFS files layout is spnfs which is good for basic testing
> but it is experimental and not very well supported currently; i.e. if it breaks
> under load you'll probably have to fix it yourself...
>
> You could also consider testing exofs - a loosely clustered, objects-based
> file system that provides scalable performance and is stable enough for
> rather intensive workloads.
>
> Benny
>
>>
>> Thanks.
>>
>> Yudong
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
