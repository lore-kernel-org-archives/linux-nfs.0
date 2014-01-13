Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cpsmtpb-ews01.kpnxchange.com ([213.75.39.4]:63617 "EHLO
	cpsmtpb-ews01.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752146AbaAMTfx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jan 2014 14:35:53 -0500
Message-ID: <1389641750.19054.9.camel@x220>
Subject: Re: [PATCH] xprtrdma: silence frame size warning
From: Paul Bolle <pebolle@tiscali.nl>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Miller David S." <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, LKML Kernel <linux-kernel@vger.kernel.org>
Date: Mon, 13 Jan 2014 20:35:50 +0100
In-Reply-To: <D3560A1A-59B3-4480-8627-9114A4B9895C@oracle.com>
References: <1389627955.20467.9.camel@x41>
	 <CDD9CEF2-F91A-4ABA-8DA7-53AF8A749194@primarydata.com>
	 <D3560A1A-59B3-4480-8627-9114A4B9895C@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-01-13 at 11:17 -0500, Chuck Lever wrote:
> I’m building a queue of NFS/RDMA work on bugzilla.kernel.org.  Let’s
> create a defect report there to document this, and it will get
> prioritized with the rest.  Paul, can you do that to start us off?
> Product “File system”, Component “NFS”.

Sure, see https://bugzilla.kernel.org/show_bug.cgi?id=68661 . Please
feel free to edit the bug's title, etc, as you see fit.

> I can’t say that a warning on 32-bit x86 is going to be an especially
> high priority.

I see. 32-bit x86 seems to be dropping in relevance quite fast.

On the other hand, this is one of the last warnings I see when currently
building x86 (32-bit, that is) and it would be rather nice to see this
warning gone. Since my .config is basically a Fedora 20 .config, that
would help make Fedora's 32-bit x86 build (almost) warning free too. 

> However, the underlying issue of allocating arrays of data segments on
> the stack is something that needs extended attention, and is already
> in plan.

Thanks,


Paul Bolle

