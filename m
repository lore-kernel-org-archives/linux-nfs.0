Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57689 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755455Ab1BCEkP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Feb 2011 23:40:15 -0500
Date: Wed, 2 Feb 2011 23:40:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: George Spelvin <linux@horizon.com>
Cc: linux-nfs@vger.kernel.org, nix@esperi.org.uk
Subject: Re: persistent, quasi-random -ESTALE at mount time
Message-ID: <20110203044010.GC30641@fieldses.org>
References: <20110203034844.GA30641@fieldses.org>
 <20110203042814.6364.qmail@science.horizon.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110203042814.6364.qmail@science.horizon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 02, 2011 at 11:28:14PM -0500, George Spelvin wrote:
> > So the reboot was for an upgrade from 2.6.26-rcX to 2.6.38-rc3?  I
> > wonder if a reboot (or just a server restart) without changing kernels
> > would see the same problem?
> 
> Whoops, typo.  It was from 2.6.36-rcX (I think -rc5, but it's scrolled
> off the logs), not .26.
> 
> > We work quite hard to ensure that filehandles returned from older nfsd's
> > will still be accepted by newer ones.  But that doesn't mean there
> > couldn't failed at that somehow in some case....
> 
> I understand that sometimes there's an incompatible server change, but

Separate from the current problem, but: no, that shouldn't be true.  If
you find a case where a kernel upgrade causes clients to fail, that's a
bug and we'd like to know about it.

> I don't ever remember a Linux-linux nfs mount surviving a server
> reboot.

Ouch.  I do test that regularly, and haven't seen problems.  Again, if
you have reproduceable problem, I'd appreciate details.--b.
