Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:43673 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752364Ab0EXKBq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 06:01:46 -0400
Date: Mon, 24 May 2010 11:09:03 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Hugh Dickins <hughd@google.com>
Cc: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org
Subject: Re: TMPFS over NFSv4
Message-ID: <20100524110903.72524853@lxorguk.ukuu.org.uk>
In-Reply-To: <AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ@mail.gmail.com>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils>
	<AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
	<AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 24 May 2010 02:57:30 -0700
Hugh Dickins <hughd@google.com> wrote:

> On Mon, May 24, 2010 at 2:26 AM, Tharindu Rukshan Bamunuarachchi
> <btharindu@gmail.com> wrote:
> > thankx a lot Hugh ... I will try this out ... (bit harder patch
> > already patched SLES kernel :-p ) ....
> 
> If patch conflicts are a problem, you really only need to put in the
> two-liner patch to mm/mmap.c: Alan was seeking perfection in
> the rest of the patch, but you can get away without it.
> 
> >
> > BTW, what does Alan means by "strict overcommit" ?
> 
> Ah, that phrase, yes, it's a nonsense, but many of us do say it by mistake.
> Alan meant to say "strict no-overcommit".

No I always meant to say 'strict overcommit'. It avoids excess negatives
and "no noovercommit" discussions.

I guess 'strict overcommit control' would have been clearer 8)

Alan
