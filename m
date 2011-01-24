Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:56355 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397Ab1AXQny convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jan 2011 11:43:54 -0500
Subject: Re: possible regression: BUG in client lockd with server reboot.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110124144107.GA3718@elliptictech.com>
Date: Mon, 24 Jan 2011 11:08:46 -0500
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <4707872F-6CC4-477D-AE0B-A7DCEEF29ABF@oracle.com>
References: <20110124144107.GA3718@elliptictech.com>
To: Nick Bowler <nbowler@elliptictech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Nick-

On Jan 24, 2011, at 9:41 AM, Nick Bowler wrote:

> We were just having some NFS server troubles, and my client machine
> running 2.6.38-rc1+ (specifically, commit 2b1caf6ed7b888c95) crashed
> hard (syslog output appended to this mail).

I don't seem to have 2b1caf6e.  Can you post the short description?

host.c:283 is " BUG_ON(!list_empty(&host->h_lockowners));" in my tree.  Can you confirm this is the same for you?

I'll have a look.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com


