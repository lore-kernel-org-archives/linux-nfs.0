Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33338 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999AbcDGOGM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2016 10:06:12 -0400
Received: by mail-pf0-f176.google.com with SMTP id 184so56648359pff.0
        for <linux-nfs@vger.kernel.org>; Thu, 07 Apr 2016 07:06:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAEUt8VJhRXn7WT8f52Wyy8B7gAPZREK1J7miCY7Rt6z__CC5uQ@mail.gmail.com>
References: <CAEUt8VJhRXn7WT8f52Wyy8B7gAPZREK1J7miCY7Rt6z__CC5uQ@mail.gmail.com>
Date: Thu, 7 Apr 2016 16:06:11 +0200
Message-ID: <CALXu0UfC3h2Rv4oQ9pSZLeMQJMqQu4zt2ywTBTMiWhmD9S6sfg@mail.gmail.com>
Subject: Re: Question : Compress files to send with NFS4.1
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Martin Houry <martinhoury@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7 April 2016 at 15:27, Martin Houry <martinhoury@gmail.com> wrote:
> Is NFS4.1 capable to compress files before sending them on the network
> and decompress them on the destination to speed up the file transfert?

You can get that with IP tunnel compression. Trouble is, NFS
(v2/v3/v4; and younger protocol designers are even worse by telling
you 'dunno care about high latency [ > 4 sec roundtrip ] any more'
[yeah? wanna pester? old RFS and AFS did a better job...]) are highly
sensitive to latency, and like ssh the high latency causes more
trouble than its worth.

Ced

>
> Kind regards,
> Martin
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
