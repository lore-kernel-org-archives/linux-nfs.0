Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:39116 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbaDWUam (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 16:30:42 -0400
Received: by mail-ie0-f170.google.com with SMTP id rd18so1489592iec.1
        for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 13:30:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140423202401.GA16168@us.ibm.com>
References: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>
	<20140423202401.GA16168@us.ibm.com>
Date: Wed, 23 Apr 2014 22:30:41 +0200
Message-ID: <CALXu0UdVYtbKQqskETk9jEK3+=nFphUtFSP4i_ey=7WwZg3-XQ@mail.gmail.com>
Subject: Re: Tuning Linux NFSv4 for high latency connections?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Cedric Blancher <cedric.blancher@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 23 April 2014 22:24, Malahal Naineni <malahal@us.ibm.com> wrote:
> Cedric Blancher [cedric.blancher@gmail.com] wrote:
>> Are there any options to improve the Linux NFSv4 performance over a
>> high latency connection?
>>
>> We currently use Solaris/Illumos as NFSv4 server and client over a
>> cross continental Internet connection. Latency is terrible (~220ms)
>> but the counter this by running work in parallel so the latency is
>> mostly mitigated.
>>
>> We now wish to migrate (short: Away from Oracle because support is
>> basically unbearable) to Linux (tested SuSE 13.1 and current Fedora)
>> and build times are 17 times (!!!) SLOWER than on Solaris/Illumos.
>>
>> Are there any tunables besides actimeo=300?
>
> rsize and wsize may help! You need to figure out if the read is the
> issue or the write before you dig further.

I already tried to tune rsize/wsize, making them both smaller or the
maximum of 1048576 bytes, with no effect.

One possible theory is that maybe something in Linux doesn't allow
multiple requests to be issued in parallel and waits for each request
to be completed before issuing the next one?

Help!

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
