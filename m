Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767AbbD2VSk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 17:18:40 -0400
Message-ID: <55414AA4.1080504@RedHat.com>
Date: Wed, 29 Apr 2015 17:18:28 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>,
        libtirpc-devel@lists.sourceforge.net
CC: linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH v2 0/7] Rebase, resend.
References: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
In-Reply-To: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/23/2015 08:27 PM, Bernhard Reutner-Fischer wrote:
> Seems i forgot the config.h stuff last time, sorry for that..
> 
> Bernhard Reutner-Fischer (7):
>   delete src/config.h
>   getrpcent: Fix compilation on glibc
>   Make sure to include config.h
I committed these three...

>   configure.ac: Allow for disabling NIS
Not this one due to due to Thorsten comments...

>   configure.ac: Allow for disabling auth DES
Committed this one. 

>   getrpcport: rephrase host lookup
This didn't apply and I had a comment about it.

>   headers: if 0 out some unbuilt functions
I reworked this one in different commit series.

steved.

> 
>  Makefile.am          |  12 ++++--
>  configure.ac         |  24 ++++++++++-
>  libtirpc.pc.in       |   2 +-
>  src/Makefile.am      |  10 +++--
>  src/auth_des.c       |  15 +++++++
>  src/auth_time.c      |   6 ++-
>  src/config.h         | 110 ---------------------------------------------------
>  src/getrpcent.c      |  16 ++++----
>  src/getrpcport.c     |  37 +++++++++++------
>  src/rpc_soc.c        |   2 +-
>  tirpc/rpc/auth.h     |  18 ++++++++-
>  tirpc/rpc/auth_des.h |   2 +
>  tirpc/rpc/rpc.h      |   2 +
>  13 files changed, 113 insertions(+), 143 deletions(-)
>  delete mode 100644 src/config.h
> 
