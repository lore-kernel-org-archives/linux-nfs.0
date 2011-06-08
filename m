Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57999 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912Ab1FHTLz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2011 15:11:55 -0400
Date: Wed, 8 Jun 2011 15:11:55 -0400
To: greearb@candelatech.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
Message-ID: <20110608191155.GB6752@fieldses.org>
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jun 08, 2011 at 10:39:08AM -0700, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> This lets one specify the source IP address for
> sockets, allowing users to leverage routing rules
> on multi-homed systems.
> 
> Kernel patches to RPC and NFS are needed to complete
> full functionality.

Possibly dumb question: there's an ongoing effort (I think--haven't
heard much from them recently?) to make the nfs and rpc code aware of
which network namespace it's running in.  Would that do what you need?

Does statd need changes too?

--b.
