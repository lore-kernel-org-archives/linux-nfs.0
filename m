Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:37610 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752077AbeFERU6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 13:20:58 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B8110814F0B8
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 17:20:57 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 99A6310F1C1A
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 17:20:57 +0000 (UTC)
Subject: Re: [PATCH 0/2] Fixing a couple warnings
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180531155525.60495-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <86493d04-6bd3-bdc4-9be2-038566fa295b@RedHat.com>
Date: Tue, 5 Jun 2018 13:20:57 -0400
MIME-Version: 1.0
In-Reply-To: <20180531155525.60495-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/31/2018 11:55 AM, Steve Dickson wrote:
> Here are a couple warnings that I started getting
> when I compiled on a freshly install Fedora 28.
> 
> The first patch turns off the compiling of rpcgen
> by default. The command produces code that cause
> a number of warnings which are now errors. 
> 
> The old glibc rpcgen, which is now in the 
> rpcsvc-proto package, does a much better job
> of not creating warnings.
> 
> The second patch fixes a couple warnings I 
> was not seeing.
> 
> Steve Dickson (1):
>   rpcgen: Only compile the command when configured.
> 
> gabriele balducci (1):
>   Fixed format overflow warnings in mountd and nfsd
> 
>  configure.ac          | 2 +-
>  utils/mountd/mountd.c | 2 +-
>  utils/nfsd/nfsd.c     | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
Committed... 

steved.
