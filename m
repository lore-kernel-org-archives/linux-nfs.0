Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35683 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933786AbcGKN5h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2016 09:57:37 -0400
Received: by mail-wm0-f46.google.com with SMTP id f65so64366985wmi.0
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2016 06:57:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <97B90495-01FF-4F00-B8F3-67A64DFFDE7C@monkey.org>
References: <CACVxJT8fYGqGbHz97xVR1fWtq3YEfQoN7180fEW-Q27UgD=3Ag@mail.gmail.com>
 <E70C1354-A1F7-47F3-A810-344BA5BE51AB@primarydata.com> <97B90495-01FF-4F00-B8F3-67A64DFFDE7C@monkey.org>
From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 11 Jul 2016 16:57:35 +0300
Message-ID: <CACVxJT_C150MAoWb6SSX-5+nd1ZZTZO8SZFt1h97+AFaw=tU3Q@mail.gmail.com>
Subject: Re: RHEL7 hang (and probably mainline) while copying big files
 because of subrequests merging(?)
To: Weston Andros Adamson <dros@monkey.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 11, 2016 at 4:48 PM, Weston Andros Adamson <dros@monkey.org> wrote:
>
>> On Jul 11, 2016, at 9:28 AM, Trond Myklebust <trondmy@primarydata.com> wrote:
>>
>>>
>>> On Jul 11, 2016, at 08:59, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>>>
>>> We have a customer who was able to reliably reproduce the following hang:
>>> (hang itself is rare but there are many machines, so it is not rare)
>>>
>>> INFO: task ascp:66692 blocked for more than 120 seconds.

> Also, you say RHEL7, but which kernel?

3.10.0-229.14.1.el7.x86_64
3.10.0-327.18.2.el7.x86_64
