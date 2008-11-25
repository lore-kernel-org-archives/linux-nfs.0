From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] Support for IPv6 in the showmount command
Date: Tue, 25 Nov 2008 09:27:56 -0500
Message-ID: <492C0B6C.7070104@RedHat.com>
References: <20081118192711.22516.2801.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58495 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935AbYKYOaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2008 09:30:15 -0500
In-Reply-To: <20081118192711.22516.2801.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> These patches implement support for rpcbind v3/v4 queries and IPv6 NFS
> servers in the showmount command.  Please consider these for the next
> release of nfs-utils.
> 
> Thanks!
> 
> ---
> 
> Chuck Lever (4):
>       showmount command: support querying IPv6 servers
>       showmount command: move logic to acquire RPC client handle out of main()
>       showmount command: Remove unused local getport() implementation
>       showmount command: call nfs_getport instead of local getport
> 
> 
>  utils/showmount/showmount.c |  237 +++++++++++++++++--------------------------
>  1 files changed, 91 insertions(+), 146 deletions(-)
All four patch have been committed and regression tested... 

steved.
