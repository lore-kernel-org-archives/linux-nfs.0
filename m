From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] First subset of nfs-utils IPv6 support
Date: Mon, 17 Nov 2008 16:13:40 -0500
Message-ID: <4921DE84.2060607@RedHat.com>
References: <20081029172134.19663.13493.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34308 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668AbYKQVPk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Nov 2008 16:15:40 -0500
In-Reply-To: <20081029172134.19663.13493.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> I sent these out yesterday, but I haven't seen them on the list or in
> mail archives.  Ah.  It's because I didn't copy the list!  So, here
> goes.
> 
> These two patches introduce a set of library functions that replace the
> separate AF_INET-only implementations in each component of nfs-utils
> (mount.nfs, showmount, sm-notify, etc) of GETPORT with a common shared
> implementation that supports both PMAP_GETPORT and RPCB_GETADDR, and
> both AF_INET and AF_INET6.  Subsequent patches will convert each
> component to use these.
> 
> These should build and operate correctly on systems without any trace
> of libtirpc libraries or headers.  On such systems, only PMAP_GETPORT
> and AF_INET is supported.
> 
> I think these are ready to be included in nfs-utils, so let's start the
> review process.
> 
> ---
> 
> Chuck Lever (2):
>       nfs-utils: Introduce rpcbind client utility functions
>       nfs-utils: Add AF_INET6-capable API to acquire an RPC CLIENT *
I apologize for the delay... Both committed..

steved.

