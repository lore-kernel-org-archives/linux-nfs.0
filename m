Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934858Ab3FSVeQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jun 2013 17:34:16 -0400
Date: Wed, 19 Jun 2013 17:34:12 -0400
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130619213412.GA2547@fieldses.org>
References: <kpscp8$fo3$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <kpscp8$fo3$1@ultimate100.geggus.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 19, 2013 at 01:47:20PM +0000, Sven Geggus wrote:
> Hello,
> 
> I just tried using Kernel 3.10.0-rc2 an my NFS-server test VM and I'm still
> unable to run a working kerberized NFS-Server with this kernel.
> 
> To make it work I would have to go back to Kernel 3.8.x (which i can't
> because I want to use drbd 8.4).
> 
> Any hints on how to furter debug this?
> 
> As I already said, I failed in "git bisecting" the Problem because the
> behaviour changed from broken behaviour (infinite hang) to another broken
> behaviour (permission denied) while doing so.

Apologies, I don't remember the previous discussion, so, could you
summarize for me?:

	- you're able to reproduce/not reproduce the problem by changing
	  *only* the kernel on the nfs server between 3.8.x and
	  3.10.0-rc2 ?
	- have you figured out exactly where the failure happens?:
	- which version of NFS are you using?

Also if you haven't already it would be useful to know at exactly which
step of the process it's failing.  As a first step running wireshark on
the traffic between client and server and looking for a NULL
init_sec_context rpc call and seeing whether it succeeds or not, would
be useful.

--b.
