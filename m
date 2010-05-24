Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:33623 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752364Ab0EXJz0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 05:55:26 -0400
Date: Mon, 24 May 2010 11:02:45 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org
Subject: Re: TMPFS over NFSv4
Message-ID: <20100524110245.6b6d847d@lxorguk.ukuu.org.uk>
In-Reply-To: <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils>
	<AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 24 May 2010 10:26:39 +0100
Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com> wrote:

> thankx a lot Hugh ... I will try this out ... (bit harder patch
> already patched SLES kernel :-p ) ....
> 
> BTW, what does Alan means by "strict overcommit" ?

Strict overcommit works like banks should. It tries to ensure that at any
point it has sufficient swap and memory to fulfill any possible use of
allocated address space. So in strict overcommit mode you should almost
never see an OOM kill (there are perverse cases as always), but you will
need a lot more swap that may well never be used.

In the normal mode the kernel works like the US banking system and makes
speculative guesses that all the resources it hands out will never be
needed at once. That has the corresponding risk that one day it might at
which point you get a meltdown (or in the kernel case OOM kills)

Alan
