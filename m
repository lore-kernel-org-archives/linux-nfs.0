Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54108 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754789Ab2LLQcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 11:32:45 -0500
Message-ID: <50C8A55C.7040502@RedHat.com>
Date: Wed, 12 Dec 2012 10:40:12 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] mountd clean-ups for nfs-utils 1.2.8
References: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
In-Reply-To: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/12/12 12:17, Chuck Lever wrote:
> Hi-
> 
> Here are four clean-up patches I've had for a while, and one patch
> that augments junction resolution debugging messages.
> 
> ---
> 
> Chuck Lever (5):
>       mountd: Report the absolute path used to load the junction plug-in
>       libexport.a: xtab.c no longer needs #include xmalloc.h
>       libexport.a: rmtab.c no longer needs #include xmalloc.h
>       mountd: cache.c no longer needs #include xmalloc.h
>       mountd: auth.c no longer needs #include xmalloc.h
> 
> 
>  support/export/rmtab.c |    6 +++---
>  support/export/xtab.c  |    2 +-
>  utils/mountd/auth.c    |    3 ++-
>  utils/mountd/cache.c   |    8 +++++++-
>  4 files changed, 13 insertions(+), 6 deletions(-)
> 
All 5 Committed.... 

steved.
