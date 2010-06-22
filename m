From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/7] Remaining IPv6 pre-requisites for mountd
Date: Tue, 22 Jun 2010 16:17:27 -0400
Message-ID: <4C211A57.6070609@RedHat.com>
References: <20100621165114.4771.51575.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753112Ab0FVURc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 16:17:32 -0400
In-Reply-To: <20100621165114.4771.51575.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/21/2010 12:54 PM, Chuck Lever wrote:
> Hi Steve-
> 
> As requested, here are the remaining seven patches that finish
> mountd's conversion from gethostby{name,addr}(3) to
> get{name,addr}info(3).
> 
> ---
> 
> Chuck Lever (7):
>       libexport.a: Remove unused hostent-based DNS helper functions
>       libexport.a: Replace matchhostname()
>       libexport.a: Add documenting comments
>       libexport.a: Make export_add() static
>       libexport.a: Make export_read() return void
>       mountd: Replace "struct hostent" with "struct addrinfo"
>       exportfs: Add a common exit label in exportfs()
> 
> 
>  support/export/client.c    |  268 +++++++++++++++++++++----------------
>  support/export/export.c    |   83 ++++++++---
>  support/export/hostname.c  |  321 ++------------------------------------------
>  support/export/rmtab.c     |   13 +-
>  support/include/exportfs.h |   20 ++-
>  support/include/misc.h     |    7 -
>  utils/exportfs/exportfs.c  |  117 +++++++++++++---
>  utils/mountd/auth.c        |   48 +++----
>  utils/mountd/cache.c       |   66 +++++----
>  utils/mountd/mountd.c      |   11 +-
>  10 files changed, 405 insertions(+), 549 deletions(-)
> 
All seven have been committed...

steved.
