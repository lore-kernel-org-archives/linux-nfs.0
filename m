From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 00/12] Next series of mountd IPv6 support patches
Date: Thu, 16 Sep 2010 17:29:54 -0400
Message-ID: <4C928C52.2090208@RedHat.com>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19723 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084Ab0IPV36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 17:29:58 -0400
In-Reply-To: <20100913171844.19017.13446.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/13/2010 01:20 PM, Chuck Lever wrote:
> This series enables support for IPv6 addresses when receiving mountd
> requests and processing export records.
> 
> The final series (later this week, or next) will enable mountd to
> listen on IPv6 transports.
> 
> ---
> 
> Chuck Lever (12):
>       libexport.a: Enable IPv6 support in hostname.c
>       mountd: Ensure cache downcall can handle IPv6 addresses
>       mountd: Handle IPv6 addresses in kernel auth_unix_ip upcalls
>       mountd: clean up cache API
>       exportfs: Enable IPv6 support in matchhostname()
>       mountd: Support IPv6 in mountlist_list()
>       mountd: Handle memory exhaustion in mountlist_list()
>       mountd: Add mountlist_freeall()
>       mountd: support IPv6 in mountlist_del_all()
>       mountd: Support IPv6 in mountd's svc routines
>       mountd: add IPv6 support in auth_authenticate()
>       libnfs.a: Fix API for getfh() & friends
> 
> 
>  support/export/hostname.c |   31 +++++++--------
>  support/include/nfslib.h  |    9 +++-
>  support/nfs/getfh.c       |   64 ++++++++++++++++++++++++++++---
>  utils/exportfs/exportfs.c |   23 +----------
>  utils/mountd/auth.c       |   52 +++++++++++++------------
>  utils/mountd/cache.c      |   57 +++++++++++++++++++++-------
>  utils/mountd/mountd.c     |   92 +++++++++++++++++++++++++++++++--------------
>  utils/mountd/mountd.h     |   11 ++++-
>  utils/mountd/rmtab.c      |   72 +++++++++++++++++++++++------------
>  9 files changed, 270 insertions(+), 141 deletions(-)
> 
All 12 patches committed... 

steved. 
