From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/6] IPv6 support for nfs-utils tcpwrapper shim
Date: Fri, 15 Jan 2010 13:04:36 -0500
Message-ID: <4B50AE34.3020009@RedHat.com>
References: <20100115174426.30104.3492.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755173Ab0AOSEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jan 2010 13:04:40 -0500
In-Reply-To: <20100115174426.30104.3492.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/15/2010 12:49 PM, Chuck Lever wrote:
> These patches provide IPv6 support for the tcpwrapper shim inside
> nfs-utils.  It assumes that the generic tcpwrapper library can
> support IPv6 addresses.  It has not been extensively tested, but
> I think the framework is reasonable, and only minor bug fixes might
> be needed as we go along.
Did you do any simple "hello world" testing?

steved.

> 
> ---
> 
> Chuck Lever (6):
>       tcpwrapper: Add support for IPv6
>       tcpwrapper: Eliminated shadowed declaration warnings
>       tcpwrapper: Fix signage problems in the tcp_wrappers hash function
>       tcp_wrapper: Clean up logit()
>       tcp_wrappers: Use getifaddrs(3) if it is available
>       tcpwrappers: Use xlog() instead of perror(3) and syslog(2)
> 
> 
>  aclocal/ipv6.m4               |    4 -
>  configure.ac                  |    2 
>  support/include/tcpwrapper.h  |   12 +-
>  support/misc/from_local.c     |  112 +++++++++++++++++++----
>  support/misc/tcpwrapper.c     |  203 ++++++++++++++++++++++++-----------------
>  utils/mountd/mount_dispatch.c |    6 -
>  utils/statd/statd.c           |    5 -
>  utils/statd/statd.man         |    3 -
>  8 files changed, 223 insertions(+), 124 deletions(-)
> 
