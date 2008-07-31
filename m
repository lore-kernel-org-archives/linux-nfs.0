From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs command: old glibc missing some flags
Date: Thu, 31 Jul 2008 05:28:01 -0400
Message-ID: <489185A1.1070908@RedHat.com>
References: <20080730235637.1447.42422.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36130 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbYGaJ2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2008 05:28:42 -0400
In-Reply-To: <20080730235637.1447.42422.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Old versions of glibc (< 2.4) have a getaddrinfo(3) implementation, but
> do not include public definitions of the AI_V4MAPPED, AI_ALL, and
> AI_ADDRCONFIG flags because it was believed that these flags were not
> standardized.  However, these flags have standard definitions both in
> POSIX 1003 and in RFCs, and were thus included in later releases of
> glibc.
> 
> To allow the mount.nfs command to build on systems with these older
> versions of glibc, add conditional definitions for these flags in
> utils/mount/network.c.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
Committed.... 

steved.
