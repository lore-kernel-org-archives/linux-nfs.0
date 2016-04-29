Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54884 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790AbcD2OtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 10:49:06 -0400
Subject: Re: [RFC PATCH v5 0/3] adding pthread support to gssd
To: Olga Kornievskaia <kolga@netapp.com>
References: <1461776287-1427-1-git-send-email-kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <57237461.9070208@RedHat.com>
Date: Fri, 29 Apr 2016 10:49:05 -0400
MIME-Version: 1.0
In-Reply-To: <1461776287-1427-1-git-send-email-kolga@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/27/2016 12:58 PM, Olga Kornievskaia wrote:
> Adding support for multi-threaded gssd and allow for parallel upcalls.
> For each upcall create a thread, detach to allow for automatic cleanup.
> Communicate location of credential cache with gss api function instead
> of an environmental variable. Use syscall api instead of libc setuid()
> to change user identity.
> 
> Previously parent thread after detaching from child thread would call
> yield to let the child thread run and consume the event from the fd.
> Instead, use synchronization variables to signal parent after reading
> from fd and have parent thread wait for the event.
> 
> Olga Kornievskaia (3):
>   gssd: use pthreads to handle upcalls
>   gssd: using syscalls directly to change thread's identity
>   gssd: always call gss_krb5_ccache_name
> 
>  aclocal/libpthread.m4  | 13 ++++++++++
>  configure.ac           |  3 +++
>  utils/gssd/Makefile.am |  3 ++-
>  utils/gssd/gssd.c      | 44 ++++++++++++++++++++++++++++++---
>  utils/gssd/gssd.h      |  5 ++++
>  utils/gssd/gssd_proc.c | 66 +++++++++++++++++++++++---------------------------
>  utils/gssd/krb5_util.c | 59 ++++++++++----------------------------------
>  utils/gssd/krb5_util.h |  1 -
>  8 files changed, 106 insertions(+), 88 deletions(-)
>  create mode 100644 aclocal/libpthread.m4
> 
All three patches have been committed... thanks for doing this work!!

steved.
