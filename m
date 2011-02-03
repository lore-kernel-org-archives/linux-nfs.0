Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:52698 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755811Ab1BCJZE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 04:25:04 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: George Spelvin <linux@horizon.com>, linux-nfs@vger.kernel.org
Subject: Re: persistent, quasi-random -ESTALE at mount time
References: <20110203034844.GA30641@fieldses.org>
	<20110203042814.6364.qmail@science.horizon.com>
	<20110203044010.GC30641@fieldses.org>
From: Nix <nix@esperi.org.uk>
Date: Thu, 03 Feb 2011 08:30:48 +0000
In-Reply-To: <20110203044010.GC30641@fieldses.org> (J. Bruce Fields's message of "Wed, 2 Feb 2011 23:40:11 -0500")
Message-ID: <87zkqdo6yv.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 3 Feb 2011, J. Bruce Fields stated:

> Ouch.  I do test that regularly, and haven't seen problems.  Again, if
> you have reproduceable problem, I'd appreciate details.--b.

I can give you a packet dump from my (completely reproducible) failure
with the same symptoms, if you like. (Again, it is fixed by running
exportfs repeatedly, each time fixing another few mounts: currently,
I have to run it six times.)
