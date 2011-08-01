Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:44470 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344Ab1HAQEA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2011 12:04:00 -0400
Received: by pzk37 with SMTP id 37so11731332pzk.1
        for <linux-nfs@vger.kernel.org>; Mon, 01 Aug 2011 09:04:00 -0700 (PDT)
In-Reply-To: <1312209731.9421.8.camel@lade.trondhjem.org>
References: <CAA4Z2ZR47Lfb_=172VUd-Qop7NiC3ewVAgUepn0WD=PDTr9k-A@mail.gmail.com>
	<1312209731.9421.8.camel@lade.trondhjem.org>
Date: Mon, 1 Aug 2011 17:03:59 +0100
Message-ID: <CAA4Z2ZRJd=uVdrmNfwY+g3c=R+iZYtOmJiRzs7gyJAadbVJo9A@mail.gmail.com>
Subject: Re: using non contiguous memory in nfs_idmap_new()
From: Adrien Kunysz <adk@acunu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 1, 2011 at 3:42 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2011-08-01 at 14:54 +0100, Adrien Kunysz wrote:
>> Dear linux-nfs,
>>
>> I have a box that has recently been victim of an OOM caused by
>> nfs_idmap_new() attempting to allocate a large amount of contiguous
>> memory. This problem has been reported previously here [0] and I
>> understand the real fix is to use CONFIG_NFS_USE_NEW_IDMAPPER. However
>> I was wondering whether using non contiguous memory instead would be a
>> valid workaround, especially considering the new ID mapper is not
>> enabled by default. I have actually written a patch to that effect as
>> I don't see any specific reason why that struct would need to be in
>> contiguous memory.
>>
>> So before I do anything stupid with that patch,
>> a) is there any good reason to use kzalloc() instead of vzalloc() in
>> nfs_idmap_new()?
>
> vmalloc memory is a limited resource too.

It certainly is but from my understanding it is much less prone to run
into problem when the memory is fragmented (which is my problem here).
I don't have a problem with how much memory it uses but with the size
of the contiguous allocation.

>> b) would you consider a patch that would make the function use vzalloc()?
>
> Is there any reason why you can't use the new idmapper now that it has
> been integrated into the upstream nfs-utils? There are so many
> scalability issues with the old idmapper that I'd rather deprecate its
> use as quickly as possible.

I must admit I feel more comfortable applying a three lines patch to
my production systems than rebuilding with the new code and upgrading
nfs-utils to a version that was released about a month ago (I assume
1.2.4 is expected to work with CONFIG_NFS_USER_NEW_IDMAPPER, I haven't
verified). I understand we all want to move to the new code ASAP but
the old code is likely to remain in use for some time and most people
are not going to switch overnight so I think it would be useful to
have a small workaround for this particular problem at least until we
just remove that code altogether.

Thanks,
Adrien
