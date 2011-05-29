Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:52510 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754356Ab1E2QzI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 12:55:08 -0400
From: =?utf-8?q?R=C3=BCdiger_Meier?= <sweet_f_a@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: Re: infinite getdents64 loop
Date: Sun, 29 May 2011 18:55:04 +0200
References: <201105281502.32719.sweet_f_a@gmx.de> <201105281700.30726.sweet_f_a@gmx.de> <1306685117.2386.7.camel@lade.trondhjem.org>
In-Reply-To: <1306685117.2386.7.camel@lade.trondhjem.org>
Content-Type: text/plain;
  charset="utf-8"
Message-Id: <201105291855.04487.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sunday 29 May 2011, Trond Myklebust wrote:

> Sorry, but that patch makes absolutely no sense whatsoever as a fix
> for the problem you describe.

It wasn't ment to be a real fix. I just tried to find out where the prob 
is roughly located. 

> All you are doing is changing the size 
> of the readdir cache entry, which is probably causing a READDIR with
> a duplicate cookie to trigger.

Yup, my patch "repaired" the test directory and let another one fail. 
Currently Ive reverted
commit d1bacf9e, NFS: add readdir cache array
(and a lot followups) to let clients work again.

> When running with the stock 2.6.39 
> client, do you see the "directory contains a readdir loop." message
> in your syslog?

Yes, didn't noticed that because I've booted 2.6.39 only a few times.
There are a lot like this:
May 25 13:26:09 kubera-114 kernel: [ 1105.419604] NFS: directory 
gen/radar contains a readdir loop.  Please contact your server vendor.  
Offending cookie: 947700512

I hope it's not my server vendor's fault :)
Or does this mean the NFS server is bad rather than the client?

cu,
Rudi
