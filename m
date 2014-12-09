Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f53.google.com ([209.85.215.53]:43605 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbaLIImn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2014 03:42:43 -0500
Received: by mail-la0-f53.google.com with SMTP id gm9so106947lab.12
        for <linux-nfs@vger.kernel.org>; Tue, 09 Dec 2014 00:42:41 -0800 (PST)
Date: Tue, 9 Dec 2014 10:42:36 +0200
From: Timo Teras <timo.teras@iki.fi>
To: David =?UTF-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>
Cc: linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH v2 0/5] rework access to /proc/net/rpc
Message-ID: <20141209104236.2204671c@vostro>
In-Reply-To: <399e974867e03c052fedfa8e8fd688ca@hardeman.nu>
References: <399e974867e03c052fedfa8e8fd688ca@hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 09 Dec 2014 09:16:59 +0100
David Härdeman <david@hardeman.nu> wrote:

> it seems that the "rework access to /proc/net/rpc" patchset removed 
> dynamic buffers in favour of static, fixed size, buffers. That seems 
> like a step backwards to me?

Depends a bit on your view. On read() side, readline() like
functionality is removed yes. Though, my understanding is so that this
is not needed with the kernel API. Maybe someone can correct me if I'm
wrong. The removal simplifies memory management, overall code size. As
probably has a positive impact on speed too (probably not too big, but
this communication is used all overall, so it might be useful).

On write() side the old code was completely wrong. It did several
assumptions on how FILE buffering works, most of them being incorrect
in general, but also glibc. It only worked because no large messages
have been sent to kernel.

> At least the readline() function could be implemented using
> read/write (instead of fread/fwrite) and a dynamic buffer...no?

It's extra complexity. I'd rather not add it unless it's required. My
understanding about the communication mechanism with kernel is that
it's not required. Why have code that would never be used?

Thanks,
Timo
