Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750893AbdGZPcz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Jul 2017 11:32:55 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D89077EA9B
        for <linux-nfs@vger.kernel.org>; Wed, 26 Jul 2017 15:32:54 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-154.rdu2.redhat.com [10.10.121.154])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9DFAC69296
        for <linux-nfs@vger.kernel.org>; Wed, 26 Jul 2017 15:32:54 +0000 (UTC)
Subject: Re: [PATCH 00/11 V2] Removed a bunch random warnings
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170721163806.15803-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <56b9641e-e463-0673-cc2d-cc9c57f089d3@RedHat.com>
Date: Wed, 26 Jul 2017 11:32:54 -0400
MIME-Version: 1.0
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/21/2017 12:37 PM, Steve Dickson wrote:
> I upgraded to Fedora 26 and went to apply Neil's recent mount 
> patches and ended up seeing all these warning. 
> 
> These patches fix those warnings
> 
> v2: change a changelog that explicitly fixes a bug.
>     Changed a number of break statements into FALLTHRU comments.
>     
> Steve Dickson (11):
>   rpcdebug.c: remove a warning
>   present_address: Fixed error path
>   atomicio: removed a warning
>   cache.c: removed a couple warning
>   nfsd.c: removed a few warnings
>   bldev_read_serial: removed a couple warnings
>   device-discovery.c: removed a warning
>   network.c: removed some warnings
>   nfsmount: remove a warning
>   nfs4mount: removed a warning
>   nfsdcltrack.c: remove a warning
> 
>  support/misc/tcpwrapper.c        | 1 +
>  support/nfs/atomicio.c           | 2 ++
>  tools/rpcdebug/rpcdebug.c        | 3 ++-
>  utils/blkmapd/device-discovery.c | 1 +
>  utils/blkmapd/device-inq.c       | 2 ++
>  utils/mount/network.c            | 5 +++++
>  utils/mount/nfs4mount.c          | 1 +
>  utils/mount/nfsmount.c           | 1 +
>  utils/mountd/cache.c             | 1 +
>  utils/nfsd/nfsd.c                | 3 +++
>  utils/nfsdcltrack/nfsdcltrack.c  | 1 +
>  11 files changed, 20 insertions(+), 1 deletion(-)
> 
Committed... Fixing those two issues Bruce point out.

steved.
