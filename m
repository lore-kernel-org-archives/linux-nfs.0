From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Subject: Re: TMPFS over NFSv4
Date: Mon, 24 May 2010 12:36:49 +0100
Message-ID: <AANLkTilrt_DXeQcl2SKtRvYTt5DKDtV9DhUyZH3KzAZ8@mail.gmail.com>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils> <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
	<20100524110245.6b6d847d@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org,
	linux-nfs@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:40369 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755361Ab0EXLhV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 07:37:21 -0400
Received: by iwn6 with SMTP id 6so3424071iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 04:37:20 -0700 (PDT)
In-Reply-To: <20100524110245.6b6d847d@lxorguk.ukuu.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Got it cleared.

BTW, nice example ... US Banking System :-)

__
tharindu.info

"those that can, do. Those that can=92t, complain." -- Linus



On Mon, May 24, 2010 at 11:02 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> w=
rote:
> On Mon, 24 May 2010 10:26:39 +0100
> Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com> wrote:
>
>> thankx a lot Hugh ... I will try this out ... (bit harder patch
>> already patched SLES kernel :-p ) ....
>>
>> BTW, what does Alan means by "strict overcommit" ?
>
> Strict overcommit works like banks should. It tries to ensure that at=
 any
> point it has sufficient swap and memory to fulfill any possible use o=
f
> allocated address space. So in strict overcommit mode you should almo=
st
> never see an OOM kill (there are perverse cases as always), but you w=
ill
> need a lot more swap that may well never be used.
>
> In the normal mode the kernel works like the US banking system and ma=
kes
> speculative guesses that all the resources it hands out will never be
> needed at once. That has the corresponding risk that one day it might=
 at
> which point you get a meltdown (or in the kernel case OOM kills)
>
> Alan
>
