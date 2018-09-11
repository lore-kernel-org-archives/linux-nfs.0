Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726689AbeIKVAY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Sep 2018 17:00:24 -0400
Subject: Re: [PATCH 00/13] libtirpc: Closed a number of memory leaks
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180907180151.178872-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <8631c942-86bc-6ab6-7802-83abe66d3164@RedHat.com>
Date: Tue, 11 Sep 2018 12:00:26 -0400
MIME-Version: 1.0
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/07/2018 02:01 PM, Steve Dickson wrote:
> There patches close a number of memory leaks that
> were found using a covscan. Most them were in error
> recovery code but a few of them were in main line code.
> 
> 
> Steve Dickson (13):
>   auth_gss.c: resource_leak
>   auth_gss.c: buffer_size_warning
>   clnt_bcast.c: resource_leak
>   clnt_vc.c: resource_leak
>   getnetconfig.c: cppcheck_warning
>   getnetpath.c: resource_leak
>   rpc_generic.c: resource_leak
>   rpc_soc.c: resource_leak
>   rpc_soc.c: buffer_size_warning
>   rpcb_clnt.c: resource_leak
>   rtime.c: resource_leak
>   svc_generic.c: resource_leak
>   svc_simple.c: resource_leak
> 
>  src/auth_gss.c     | 3 ++-
>  src/clnt_bcast.c   | 1 +
>  src/clnt_vc.c      | 2 ++
>  src/getnetconfig.c | 2 ++
>  src/getnetpath.c   | 1 +
>  src/rpc_generic.c  | 1 +
>  src/rpc_soc.c      | 8 ++++++--
>  src/rpcb_clnt.c    | 1 +
>  src/rtime.c        | 1 +
>  src/svc_generic.c  | 1 +
>  src/svc_simple.c   | 1 +
>  11 files changed, 19 insertions(+), 3 deletions(-)
> 
Committed (tag: libtirpc-1-1-5-rc1)
