Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40103 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbZEMAEm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2009 20:04:42 -0400
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Matt Helsley <matthltc@us.ibm.com>, Containers <containers@lists.osdl.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC][PATCH] Improve NFS use of network and mount namespaces
References: <20090512215138.GD3912@us.ibm.com>
	<1242172010.5407.79.camel@heimdal.trondhjem.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 12 May 2009 17:04:39 -0700
In-Reply-To: <1242172010.5407.79.camel@heimdal.trondhjem.org> (Trond Myklebust's message of "Tue\, 12 May 2009 19\:46\:50 -0400")
Message-ID: <m13ab97trc.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> Finally, what happens if someone decides to set up a private socket
> namespace, using CLONE_NEWNET, without also using CLONE_NEWNS to create
> a private mount namespace? Would anyone have even the remotest chance in
> hell of figuring out what filesystem is mounted where in the ensuing
> chaos?

Good question.  Multiple NFS servers with the same ip address reachable
from the same machine sounds about as nasty pickle as it gets.

The only way I can even imagine a setup like that is someone connecting
to a vpn.  So they are behind more than one NAT gateway.

Bleh NAT sucks.

Eric
