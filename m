Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39784 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030496AbeCANUn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Mar 2018 08:20:43 -0500
Subject: Re: [PATCH v3 0/4] Avoid IANA-assigned port numbers
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
References: <20180225180530.2983.82980.stgit@klimt.1015granger.net>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <ae38edf4-fa79-e1e9-53fd-92956d27acc2@RedHat.com>
Date: Thu, 1 Mar 2018 08:20:42 -0500
MIME-Version: 1.0
In-Reply-To: <20180225180530.2983.82980.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/25/2018 01:17 PM, Chuck Lever wrote:
> Following up on https://bugzilla.linux-nfs.org/show_bug.cgi?id=320 .
> 
> Here's a possible way to get libtirpc to avoid IANA-assigned port
> numbers when a caller requests a dynamically-assigned port. This
> approach also reduces the number of reserved ports used by long
> running user space RPC daemons, and can be applied in combination
> with changing bindresvport(3) to skip port numbers that appear in
> /etc/services.
> 
> Changes since v2:
> - make port assignment more random across serial callers and
>   processes
> 
> Changes since RFC:
> - fixed bugs
> - re-organized the patches slightly
> - clarified the patch descriptions
The series was committed... Thank you!

steved.
> 
> ---
> 
> Chuck Lever (4):
>       Add an internal helper for binding to a dynamically-assigned port
>       Avoid choosing reserved ports in svc_tli_create(3)
>       Avoid choosing reserved ports in clnt_tli_create(3)
>       Avoid choosing reserved ports in legacy RPC APIs
> 
> 
>  src/Makefile.am    |    5 +-
>  src/binddynport.c  |  139 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  src/clnt_generic.c |    4 +
>  src/rpc_soc.c      |   10 +---
>  src/svc_generic.c  |   12 +---
>  5 files changed, 153 insertions(+), 17 deletions(-)
>  create mode 100644 src/binddynport.c
> 
> --
> Chuck Lever
> 
