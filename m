Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:56043 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab2JaO2M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2012 10:28:12 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so2108663iea.19
        for <linux-nfs@vger.kernel.org>; Wed, 31 Oct 2012 07:28:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <k6r6ur$eva$2@ultimate100.geggus.net>
References: <k6ebva$1kf$1@ultimate100.geggus.net>
	<20121026171549.GA11806@fieldses.org>
	<20121029094038.GA14836@geggus.net>
	<20121029150203.GB9502@fieldses.org>
	<20121029163323.GA24345@geggus.net>
	<k6r6ur$eva$2@ultimate100.geggus.net>
Date: Wed, 31 Oct 2012 07:28:11 -0700
Message-ID: <CAA7C2qiiHzwMmkm5fUyNCffejxACtsDu0Pb1qgYJPCfgcaZU-w@mail.gmail.com>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
From: VDR User <user.vdr@gmail.com>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 31, 2012 at 5:52 AM, Sven Geggus
<lists@fuchsschwanzdomain.de> wrote:
>>> I'd be curious to understand what changed on the server to make a
>>> difference.
>>
>> Nothing but the kernel. I'm currently dual booting either 3.5.7 or 3.6.3
>> vanilla kernels on the same system.
>
> I did some further investigation on this using a freshly installed
> system on virtualbox with either kernel.
>
> Same odd behaviour. Everything work using Kernel 3.5.7. Server does not work using
> Kernel 3.6.3.
>
> There are even different filesystems on the vm (ext4) and on the real server
> (xfs).
>
> Looks like I need to cherry-pick nfs4 server changes between 3.5.7 and 3.6.3 now :(

In case you missed my previous message, "I use debian testing here and
NFSv4. My clients are running kernel
3.6.3, server is running 3.6.2.  No problems here". It would seem you
only need to cherry-pick server changes between 3.6.2 and 3.6.3...?
