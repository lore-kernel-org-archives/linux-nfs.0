From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] Two more patches related to mountd IPv6 support
Date: Mon, 24 May 2010 06:03:25 -0400
Message-ID: <4BFA4EED.4070707@RedHat.com>
References: <20100507174128.4221.36914.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46710 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220Ab0EXKD3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 06:03:29 -0400
In-Reply-To: <20100507174128.4221.36914.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/07/2010 01:45 PM, Chuck Lever wrote:
> Steve-
> 
> Here are two more minor clean-up patches for IPv6 support in mountd.
> The second patch defines the format in which IPv6 address are stored
> in rmtab.  Since IPv6 addresses are new to this file, I hope there are
> no backward-compatibility concerns about this change, but please let
> me know if there might be a problem.
> 
> ---
> 
> Chuck Lever (2):
>       mountd: Convert colons in IPv6 presentation addresses to semicolons
>       libexport.a: Refactor rmtab_read()
> 
> 
>  support/export/rmtab.c |   64 +++++++++++++++++++++++++++++++-----------------
>  support/nfs/rmtab.c    |   42 +++++++++++++++++++++++++++++---
>  2 files changed, 80 insertions(+), 26 deletions(-)
> 
Committed...

steved.
