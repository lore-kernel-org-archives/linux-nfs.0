Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:43824 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbaHNQ5S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 12:57:18 -0400
Received: by mail-ig0-f180.google.com with SMTP id l13so5616155iga.1
        for <linux-nfs@vger.kernel.org>; Thu, 14 Aug 2014 09:57:17 -0700 (PDT)
Content-Type: text/plain; charset=iso-8859-1
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: fuzz testing a 32 bit UML guest with NFSv4 gave: BUG kmalloc-256 (Not tainted): Redzone overwritten
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <53ECE285.4080200@gmx.de>
Date: Thu, 14 Aug 2014 12:57:14 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Weston Andros Adamson <weston.adamson@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <1E9DB9D4-A4DF-4D58-918F-DAFE0004E2C0@primarydata.com>
References: <53D4CAA7.2000005@gmx.de> <CAHQdGtRqeQXEP1+VV5UUYSdobwNjWNt8y11HC_Zb891A+t9FFQ@mail.gmail.com> <7B49B65C-3CD6-43AD-AB11-B3DDC52199FA@primarydata.com> <B5E517A7-303C-40B6-99B4-1FEF72EBFEB1@primarydata.com> <53ECE285.4080200@gmx.de>
To: =?iso-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, that was from a backport.

The correct commit is:

commit 6094f83864c1d1296566a282cba05ba613f151ee
Author: Weston Andros Adamson <dros@primarydata.com>
Date:   Thu May 15 11:56:50 2014 -0400

    nfs: allow coalescing of subpage requests

My fix seems to work, but I still need to clean it up a bit.

-dros



On Aug 14, 2014, at 12:23 PM, Toralf Förster <toralf.foerster@gmx.de> wrote:

> On 08/14/2014 12:00 AM, Weston Andros Adamson wrote:
>> There are two solutions:
>> 
>> 1) introduce a new check in nfs_can_coalesce_requests - basically the same
>>    tests as were removed in commit 362251a0eb540cf2537d78d508b2bcd87fe66321, but each with:
>>   && req->wb_page != prev->wb_page.
> 
> Hhm,
> 
> tfoerste@n22 ~/devel/linux $ git show 362251a0eb540cf2537d78d508b2bcd87fe66321
> fatal: bad object 362251a0eb540cf2537d78d508b2bcd87fe66321
> 
> 
> -- 
> Toralf
> 

