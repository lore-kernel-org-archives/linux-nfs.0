Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44967 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754619Ab1CWRCq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 13:02:46 -0400
Subject: Re: [PATCH 0/4] RFC: RPC over AF_LOCAL, kernel client-side
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <B2821425-392E-4212-94FD-75D232CD4B28@oracle.com>
References: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
	 <B08BDAF0-04A9-42ED-ACCE-6291E0F6BF4E@netapp.com>
	 <B2821425-392E-4212-94FD-75D232CD4B28@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 13:02:27 -0400
Message-ID: <1300899747.11677.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 11:56 -0400, Chuck Lever wrote:
> On Mar 23, 2011, at 11:26 AM, Andy Adamson wrote:
> 
> > Are you reviving the "RPC Upcall" that I implemented 10 years ago?
> 
> This patchset doesn't specifically revive that idea, as its narrow purpose is to replace kernel rpcbind registration over network loopback.
> 
> But the work could be a pre-requisite for a generic upcall mechanism over RPC.  An AF_LOCAL transport can be used as a generic upcall mechanism if user space services set up an AF_LOCAL listener.
> 
> I'm guessing ten years ago there wasn't built-in standardized support for AF_LOCAL RPC transports in the glibc RPC implementation, which may have impeded the success of such a proposal back then.  libtirpc makes AF_LOCAL a little more practical, as the incremental cost of supporting AF_LOCAL for any user space service is now minimal.

No. The idea was rejected simply because there is no need for all that
XDR overhead when we're talking to a process on the same machine.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

