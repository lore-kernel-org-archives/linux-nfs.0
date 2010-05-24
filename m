From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Subject: Re: TMPFS over NFSv4
Date: Mon, 24 May 2010 15:16:47 +0100
Message-ID: <AANLkTikjyi1XUzO2VySrXL1evPCRx8YepOAs0I9HCvtp@mail.gmail.com>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils> <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
	<AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Hugh Dickins <hughd@google.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:49753 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757006Ab0EXORT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 10:17:19 -0400
Received: by gwaa20 with SMTP id a20so1499859gwa.19
        for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 07:17:17 -0700 (PDT)
In-Reply-To: <AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi Hugh.

On Mon, May 24, 2010 at 10:57 AM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, May 24, 2010 at 2:26 AM, Tharindu Rukshan Bamunuarachchi
>
> If patch conflicts are a problem, you really only need to put in the
> two-liner patch to mm/mmap.c: Alan was seeking perfection in
> the rest of the patch, but you can get away without it.
>

I will just add it by hand.

>
>
> So what you see fits with what Alan was fixing.
>

Yes, of courese.

BTW, that was typo and it should be overcommit_memory.
I have done testing in our test severs and "2 > overcommit_memory"
triggers the issue.

OTOH, I have reported the issue Novell.
Hope they will apply necessary patch in next release.


> Hugh
>


Thankx a lot/

__
tharindu
