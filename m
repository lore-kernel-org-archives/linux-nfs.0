Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:41389 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab2AXPBu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2012 10:01:50 -0500
Message-ID: <4F1EC7C9.2020001@panasas.com>
Date: Tue, 24 Jan 2012 17:01:29 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Stanislaw Gruszka <sgruszka@redhat.com>,
        Stephen Boyd <sboyd@codeaurora.org>, <linux-kernel@vger.kernel.org>,
        <bfields@redhat.com>, <linux-nfs@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>
Subject: Re: WARNING: at lib/debugobjects.c:262 debug_print_object+0x8c/0xb0()
References: <20120120135646.2fc4fa61@tlielax.poochiereds.net> <4F1BCCD6.4020603@codeaurora.org> <20120123102311.4378b8c1@tlielax.poochiereds.net> <20120124074516.GC2420@redhat.com> <4F1E7F3F.3060703@panasas.com> <20120124073626.552bc31c@tlielax.poochiereds.net>
In-Reply-To: <20120124073626.552bc31c@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/24/2012 02:36 PM, Jeff Layton wrote:
> 
> No, I don't think the state would be undefined after
> cancel_delayed_work_sync. In principle you could requeue that work
> again if you like without needing to reinitialize it.
> 
> I think this is a problem in the debugobjects code. It doesn't have
> any way to know that when the object is recycled out of the slab that
> the work is already initialized.
> 

The only difference between your above example of requeue after
cancel_delayed_work_sync, and this here is the visit back to the
slab. Does the slab (Maybe in debug mode) stumps over some of the
record memory?

If the memory is constant what is then the difference between the two
cases?

> Certainly it's simple enough to reinitialize the work every time we
> allocate an inode here, but I don't think this is really a rpc_pipefs
> bug per-se. 

That depends on the API intention. If an init is intended after
SLAB free then yes if not then not. We should ask for the intention
of this API.

> I can send a patch that works around this problem, but
> if there are plans to fix this in the debugobjects code, I won't
> bother...
> 

You mean other fix then calling INIT_DELAYED_WORK? is that so
bad that we need more code to avoid it?

Thanks
Boaz
