From: Alexander Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: Re: Help please
Date: Thu, 17 Jun 2010 22:42:52 +1000
Message-ID: <AANLkTinPbTJ7xrcCHnAP54OKjY5HjZjmA4H4zJjFmeqf@mail.gmail.com>
References: <AANLkTinQkRf_ZkN5qw1rsK5MY7pB1NjFd5CiLaPa-ZOU@mail.gmail.com>
	<1276607740.4922.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:44804 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156Ab0FQMmx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 08:42:53 -0400
Received: by iwn9 with SMTP id 9so6739303iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 05:42:52 -0700 (PDT)
In-Reply-To: <1276607740.4922.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 15, 2010 at 11:15 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Tue, 2010-06-15 at 12:01 +1000, Alexander Samad wrote:
>> Hi
>>
>> sorry if this is a duplicate, I have been having some problem
>> subscribing to the ml.
>>
>>
>>
>> I am having some problem with nfs-kernel on a debian amd64 (sid) =A0=
i am
>> using version (1:1.2.2-1).
>>
>> when I do a tcpdump on my nfs machine and do a mount -o vers=3D4,udp
>> nfs:/exports/video /exports/video/ it fails
>
> UDP transport is not supported by the NFSv4 protocol. Some servers ma=
y
> allow it, but most will not.

okay, but why does the nfs-kernel on linux look like it is sending
packets (via udp), but they are not hitting the wire.


>
> Cheers
> =A0Trond
>
>
