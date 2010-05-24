Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:21132 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755629Ab0EXJ5f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 05:57:35 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o4O9vWY2017930
	for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 02:57:33 -0700
Received: from vws3 (vws3.prod.google.com [10.241.21.131])
	by hpaq6.eem.corp.google.com with ESMTP id o4O9vLGc014350
	for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 02:57:31 -0700
Received: by vws3 with SMTP id 3so249713vws.28
        for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 02:57:31 -0700 (PDT)
In-Reply-To: <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils>
	<AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
Date: Mon, 24 May 2010 02:57:30 -0700
Message-ID: <AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ@mail.gmail.com>
Subject: Re: TMPFS over NFSv4
From: Hugh Dickins <hughd@google.com>
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 24, 2010 at 2:26 AM, Tharindu Rukshan Bamunuarachchi
<btharindu@gmail.com> wrote:
> thankx a lot Hugh ... I will try this out ... (bit harder patch
> already patched SLES kernel :-p ) ....

If patch conflicts are a problem, you really only need to put in the
two-liner patch to mm/mmap.c: Alan was seeking perfection in
the rest of the patch, but you can get away without it.

>
> BTW, what does Alan means by "strict overcommit" ?

Ah, that phrase, yes, it's a nonsense, but many of us do say it by mistake.
Alan meant to say "strict no-overcommit".

>
> e.g.
> i did not see this issues with "0 > /proc/sys/vm/overcommit_accounting"

I assume "overcommit_accounting" is either a typo for "overcommit_memory",
or SLES gives "overcommit_memory" a slightly different name.

0 means overcommit memory (let people allocate more private writable user
memory than there is actually ram+swap to back), but throw in a check against
really wild allocation requests.  1 omits even that check.

> But this happened several times with "2 > /proc/sys/vm/overcommit_accounting"

2 means account for all private writable memory and fail any allocation which
would take the system over the edge - the edge being defined roughly by
overcommit_ratio * (ram+swap)  (I expect there's a divisor needed in there!)
i.e. 2 means strict no-overcommit.

So what you see fits with what Alan was fixing.

Hugh
