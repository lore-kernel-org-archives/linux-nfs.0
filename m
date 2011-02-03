Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:33177 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755836Ab1BCE2Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Feb 2011 23:28:16 -0500
Date: 2 Feb 2011 23:28:14 -0500
Message-ID: <20110203042814.6364.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: bfields@fieldses.org, linux@horizon.com
Subject: Re: persistent, quasi-random -ESTALE at mount time
Cc: linux-nfs@vger.kernel.org, nix@esperi.org.uk
In-Reply-To: <20110203034844.GA30641@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

> So the reboot was for an upgrade from 2.6.26-rcX to 2.6.38-rc3?  I
> wonder if a reboot (or just a server restart) without changing kernels
> would see the same problem?

Whoops, typo.  It was from 2.6.36-rcX (I think -rc5, but it's scrolled
off the logs), not .26.

> We work quite hard to ensure that filehandles returned from older nfsd's
> will still be accepted by newer ones.  But that doesn't mean there
> couldn't failed at that somehow in some case....

I understand that sometimes there's an incompatible server change, but
I don't ever remember a Linux-linux nfs mount surviving a server
reboot.

However, the problem I'm complaining about here is more alarming.  With
a clean client, attempting to *mount* is failing with -ESTALE.

> If you manage to reproduce the problem, /proc/fs/nfs/exports before and
> after the reboot would be interesting, and ideally also a network trace
> showing traffic before and after the reboot (including the operation
> that returned the STALE error).

Can do.  How much detail do you want in the packet trace?  Is -vvv
enough, or do you want -X as well?

Thank you very much for the response; I'll try to reproduce and
capture the problem.
-- 
	-Colib
