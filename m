Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754963Ab1BHQHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 11:07:31 -0500
Message-ID: <4D516A3F.8050200@RedHat.com>
Date: Tue, 08 Feb 2011 11:07:27 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: peter honeyman <honey@citi.umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] cthon: remove extraneous files
References: <20110207190513.GA4036@merit.edu>
In-Reply-To: <20110207190513.GA4036@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

FYI...

On 02/07/2011 02:05 PM, Jim Rees wrote:
> These are generated files and don't belong in the distribution.
> 
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  general/large1.c |  443 ------------------------------------------------------
>  general/large2.c |  443 ------------------------------------------------------
>  general/large3.c |  443 ------------------------------------------------------
>  3 files changed, 0 insertions(+), 1329 deletions(-)
>  delete mode 100644 general/large1.c
>  delete mode 100644 general/large2.c
>  delete mode 100644 general/large3.c
I committed this patch as well as my nroff fixes to
   git://linux-nfs.org/~steved/cthon04.git

steved.

