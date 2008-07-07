From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Mon, 07 Jul 2008 14:20:20 -0400
Message-ID: <1215454820.19512.25.camel@localhost>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
	 <20080703204543.GI30918@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30220 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754457AbYGGSU3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2008 14:20:29 -0400
In-Reply-To: <20080703204543.GI30918@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-07-03 at 16:45 -0400, J. Bruce Fields wrote:
> On Mon, Jun 30, 2008 at 06:38:35PM -0400, Chuck Lever wrote:
> > Hi Trond-
> > 
> > Seven patches that implement kernel RPC service registration via rpcbind v4.
> > This allows the kernel to advertise IPv4-only services on hosts with IPv6
> > addresses, for example.
> 
> This is Trond's baliwick, but I read through all 7 quickly and they
> looked good to me....

They look more or less OK to me too, however I'm a bit unhappy about the
RPC_TASK_ONESHOT name: it isn't at all descriptive.

I also have questions about the change to a TCP socket here. Why not
just implement connected UDP sockets?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
