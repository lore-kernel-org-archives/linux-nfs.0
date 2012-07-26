Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:32833 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040Ab2GZN5f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 09:57:35 -0400
Received: by ghrr11 with SMTP id r11so1983045ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2012 06:57:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50113504.3060607@panasas.com>
References: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com>
 <500FCA3A.5020606@panasas.com> <CA+a=Yy58bjUMximWOMnmk0ugPKUY-LcacRhpdp4cvuz1HQG_gg@mail.gmail.com>
 <5010573F.4000901@panasas.com> <CA+a=Yy5oJObMeUuL-mspso2eXCr4+5qmiFsOfS5=fU5x9kHtkw@mail.gmail.com>
 <5010F1DF.3060905@panasas.com> <CA+a=Yy5YNKp2tkOreYwV9sfm7whw3_KeRj_YCCL3abG6+csK=g@mail.gmail.com>
 <50113504.3060607@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 26 Jul 2012 21:57:13 +0800
Message-ID: <CA+a=Yy6+7G_-Mef+dEZKqftjwgubMxboCLB9YB4DdrDJoznXvQ@mail.gmail.com>
Subject: Re: pnfs LD partial sector write
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 26, 2012 at 8:16 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 07/26/2012 11:25 AM, Peng Tao wrote:
>
>> For these two sectors, I need to allocate two pages... Just look at
>> struct bio_vec.
>>
>
>
> NO! I know all about bio_vecs
>
> You need 1024 bytes, and 2 x one entry BIOs which is a few bytes, where
> did you get the "two pages" from?
>
What do you put int bio_vec->bv_page? Even if you just use 512 bytes
of a page, it is still allocated page.

-- 
Thanks,
Tao
