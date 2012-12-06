Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f46.google.com ([209.85.219.46]:58299 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088Ab2LFOKJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Dec 2012 09:10:09 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so6288155oag.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 Dec 2012 06:10:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B33820F@SACEXCMBX04-PRD.hq.netapp.com>
References: <50BF07C4.7060505@tonian.com> <4FA345DA4F4AE44899BD2B03EEEC2FA90B33820F@SACEXCMBX04-PRD.hq.netapp.com>
From: Benny Halevy <bhalevy@tonian.com>
Date: Thu, 6 Dec 2012 16:09:48 +0200
Message-ID: <CAEMWVhvHQ_Hhp9zbYw9pzj8PGCRO9ap8dwitMTU=OY_9LKO+oA@mail.gmail.com>
Subject: Re: pnfs wiki pages
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS list <linux-nfs@vger.kernel.org>,
        "Douglas O'Flaherty" <douglas@tonian.com>,
        Ross Safko <ross@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 6, 2012 at 12:36 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>> owner@vger.kernel.org] On Behalf Of Benny Halevy
>> Sent: Wednesday, December 05, 2012 9:37 AM
>> To: NFS list
>> Cc: Douglas O'Flaherty; Ross Safko
>> Subject: pnfs wiki pages
>>
>> The pages under http://wiki.linux-
>> nfs.org/wiki/index.php/PNFS_prototype_design
>> are terribly outdated.
>>
>> I'd like to move the obsolete stuff under "Historical Contents", leave what's
>> current, and refresh some of the pages.
>
> Do we really need to document the "pNFS prototype" design at this point? :-)

Good point.

> Documentation on the _final_ pNFS code design on the other hand will be very welcome (and, yes, I do include the server design as part of the "final" label).

I added http://wiki.linux-nfs.org/wiki/index.php/PNFS_Server_Filesystem_API_Design

We probably want to have something similar for the layout driver API,
as well as more detailed documentation under
Documentation/filesystems/nfs,
as well as some internal design topics like locking, memory
allocation, page operations etc.

Benny

>
>> Any objections?
>
> None whatsoever. By all means do please proceed...
>
> Thanks!
>    Trond
