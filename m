Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754386Ab2E2TQd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 15:16:33 -0400
Message-ID: <4FC52067.5040101@RedHat.com>
Date: Tue, 29 May 2012 15:15:51 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: Re: [PATCH] autoconf: make the test for prctl have an effect
References: <1337267688-3957-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337267688-3957-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/17/2012 11:14 AM, Jeff Layton wrote:
> We currently test to ensure that prctl() is available, but the results
> of that test are a no-op either way. statd calls prctl()
> unconditionally, so make configure bail out if prctl() isn't available
> since the build will fail in that event anyway.
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed....

steved.
> ---
>  aclocal/libcap.m4 |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/aclocal/libcap.m4 b/aclocal/libcap.m4
> index 68a624c..f8a0ed1 100644
> --- a/aclocal/libcap.m4
> +++ b/aclocal/libcap.m4
> @@ -3,7 +3,7 @@ dnl
>  AC_DEFUN([AC_LIBCAP], [
>  
>    dnl look for prctl
> -  AC_CHECK_FUNC([prctl], , )
> +  AC_CHECK_FUNC([prctl], , AC_MSG_ERROR([prctl syscall is not available]))
>  
>    AC_ARG_ENABLE([caps],
>      [AS_HELP_STRING([--disable-caps], [Disable capabilities support])])
