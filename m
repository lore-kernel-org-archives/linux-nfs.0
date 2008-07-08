From: "Jesper Krogh" <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: Re: 2.6.26-rc5 call trace
Date: Tue, 8 Jul 2008 17:37:53 +0200 (CEST)
Message-ID: <44399.195.41.66.226.1215531473.squirrel@mail.jabbernet.dk>
References: <18129.195.41.66.226.1215508839.squirrel@mail.jabbernet.dk>
    <20080708144156.GC7032@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Jesper Krogh" <jesper-Q2TZfHgGEy4@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:41497 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753283AbYGHPiQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2008 11:38:16 -0400
In-Reply-To: <20080708144156.GC7032@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> What filesystem are you exporting, with what export options?  And with
> which kernel version did you start seeing this?

ext3 filesystems with these exports:
               *(rw,async,no_subtree_check)

I havent seen it running -rc4 but the trace first arrived after 29 days of
uptime on -rc5 and i dont think I have run -rc4 that long.

Jesper

-- 
Jesper Krogh

