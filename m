Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754967Ab2K1U2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 15:28:20 -0500
Date: Wed, 28 Nov 2012 15:28:13 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Subject: Re: NFSd in container - it works
Message-ID: <20121128152813.2b4c388d@tlielax.poochiereds.net>
In-Reply-To: <20121128200126.GA17875@fieldses.org>
References: <50B64628.4070007@parallels.com>
	<20121128200126.GA17875@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 28 Nov 2012 15:01:26 -0500
"bfields@fieldses.org" <bfields@fieldses.org> wrote:

> > 3) Holding net by tracker looks redundant. What was the reason for this?
> 
> I don't understand, what's tracker?

I assume he means the clientid tracker. That was necessary for the
nfsdcld upcall because it used rpc_pipefs files, and those were
net-namespacified. Once we deprecate that in 3.10, I don't think we'll
need to worry about the net namespace in the clientid tracker.

We probably *will* need to concern ourselves with the mnt namespace
there though since each container will presumably have its own clientid
database...

-- 
Jeff Layton <jlayton@redhat.com>
