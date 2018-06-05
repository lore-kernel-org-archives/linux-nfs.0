Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752055AbeFERVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 13:21:35 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2D2564187E4C
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 17:21:35 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0C211205D521
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 17:21:34 +0000 (UTC)
Subject: Re: [PATCH 0/4] Removed more warnings that now errors via -W
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180604145051.146390-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <970c9873-e9d5-1962-8a8f-16f8ac50034c@RedHat.com>
Date: Tue, 5 Jun 2018 13:21:33 -0400
MIME-Version: 1.0
In-Reply-To: <20180604145051.146390-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/04/2018 10:50 AM, Steve Dickson wrote:
> The patches remove more warnings that are errors via the -W flags. 
> Basically allows RHEL7 to compile with following flags:
> 
> -Wformat=2 -Wmissing-include-dirs \
> -Wunused -Wlogical-op \
> -Wmissing-prototypes -Wmissing-declarations -Wstrict-prototypes \
> -Wmissing-noreturn -Wshadow \
> -Wunreachable-code -Wdisabled-optimization \
> -fstrict-aliasing -fstrict-overflow \
> -fexceptions -fstack-protector \
> -fasynchronous-unwind-tables -fpie" \
> 
> There are still warnings but there are no more fatel errors. 
> 
> 
> Steve Dickson (4):
>   xtab.c: Removed overflow in implicit constant conversion errors
>   Removed ISO C does not support the '%m' gnu_printf format errors
>   Removed format expects argument of type errors
>   gssd.c: Remomved a couple of warning errors
> 
>  support/include/exportfs.h |  2 +-
>  utils/gssd/gssd.c          | 20 ++++++++++----------
>  utils/idmapd/idmapd.c      |  3 ++-
>  utils/nfsidmap/nfsidmap.c  |  2 +-
>  utils/nfsstat/nfsstat.c    |  6 +++---
>  utils/statd/statd.c        |  7 ++++---
>  6 files changed, 21 insertions(+), 19 deletions(-)
> 
Committed... with the nit fixed.

steved.
