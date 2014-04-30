Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753180AbaD3RVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2014 13:21:43 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s3UHLBWn007846
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2014 13:21:42 -0400
Message-ID: <53612518.5000401@RedHat.com>
Date: Wed, 30 Apr 2014 12:30:16 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/6] gssd: add the GSSAPI acceptor name to the info
 passed in downcall
References: <1397575172-28377-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397575172-28377-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/15/2014 11:19 AM, Jeff Layton wrote:
> v2:
> - add patch to reset lifetime_rec if gss_inquire_context fails
> - ensure that we always send the length in the downcall, even if
>   there is no acceptor string.
> - comment and error handling fixups (primarily in last patch)
> 
> Recently, I started a mailing list thread about some authentication
> failures that I was seeing on the callback channel when krb5 was in use.
> 
> After a bit of discussion we determined that the right way to fix it
> was to save off the GSSAPI acceptor name used in the SETCLIENT call,
> and then ensure that the same principal is used in callback requests.
> 
> This patchset is the userland portion of that change. It basically
> just adds the acceptor name to the downcall, immediately following
> the context token. Older kernel will just ignore this data, so this
> should be safe.
> 
> There is also a companion kernel patchset that will allow the kernel
> to save off this info for later usage.
> 
> Jeff Layton (6):
>   gssd: handle malloc failure appropriately in do_downcall
>   gssd: make do_downcall a void return
>   gssd: move hostbased name routines into separate file
>   gssd: add new routine for generating a hostbased principal in a
>     gss_buffer_t
>   gssd: explicitly set lifetime_rec to 0 when gss_inquire_context fails
>   gssd: scrape the acceptor name out of the context
> 
>  utils/gssd/Makefile.am    |   2 +
>  utils/gssd/gss_names.c    | 138 ++++++++++++++++++++++++++++++++++++++++++++++
>  utils/gssd/gss_names.h    |  36 ++++++++++++
>  utils/gssd/gssd_proc.c    |  53 ++++++++++++------
>  utils/gssd/svcgssd_proc.c |  66 +---------------------
>  5 files changed, 214 insertions(+), 81 deletions(-)
>  create mode 100644 utils/gssd/gss_names.c
>  create mode 100644 utils/gssd/gss_names.h
> 
Committed... All six patches...

steved.

