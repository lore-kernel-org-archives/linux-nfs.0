Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35696 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061Ab2AaO4D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2012 09:56:03 -0500
Message-ID: <4F2800B4.6040302@panasas.com>
Date: Tue, 31 Jan 2012 16:54:44 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] sunrpc: initialize delayed work on each rpc_inode allocation
References: <1327426850-14837-1-git-send-email-jlayton@redhat.com> <4F2700E2.9020803@RedHat.com> <1327957652.4090.32.camel@lade.trondhjem.org> <20120130185753.50280816@tlielax.poochiereds.net>
In-Reply-To: <20120130185753.50280816@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/31/2012 01:57 AM, Jeff Layton wrote:
>     WARNING: at lib/debugobjects.c:262 debug_print_object+0x8c/0xb0()
> 
> For now, this patch is really just papering over that problem, but it
> should be "mostly harmless". That said, I'm ok with dropping it if
> Thomas is planning to fix this in the debugobjects code however.
> 

I disagree it's harmless. What if kmem_cache_free/kmem_cache_alloc deploys
a poisoning schema, in debug mode. Which stumps over memory. Is it
initialized then?

What was the last state of the timer, is it safe for resume?

For us this is a new object we should initialize it.

Boaz
