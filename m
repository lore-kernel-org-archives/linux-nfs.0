Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbbCZRAK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2015 13:00:10 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t2QH0A4b008237
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 26 Mar 2015 13:00:10 -0400
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t2QH09IH007010
	for <linux-nfs@vger.kernel.org>; Thu, 26 Mar 2015 13:00:10 -0400
Message-ID: <55143B19.3090003@RedHat.com>
Date: Thu, 26 Mar 2015 13:00:09 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: rpc.mountd reads /etc/mtab 17028 times, 100% CPU.
References: <20150325093707.GC26088@dot.freshdot.net>
In-Reply-To: <20150325093707.GC26088@dot.freshdot.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/25/2015 05:37 AM, Sander Smeenk wrote:
> I'm running a server that has 1500+ mounted local filesystems.
> All of these local filesystems are exported through NFS by this server.
> 
> When an NFS-client tries to access one of these exported filesystems,
> for example doing a simple 'ls' in a mounted NFS, rpc.mountd on the
> server takes 100% CPU and starts to spin over reading /etc/mtab which is
> linked to /proc/mounts and totals to about 200KB in size. The client
> stalls all the while rpc.mountd is busy reading /etc/mtab for every
> filesystem mounted, and then some more.
> 
> This entire process of reading /etc/mtab 17028 times takes a lot of time
> during which the client stalls, but in the end 'it just works fine'.
> It just takes ages when you try to tab-complete on a client.
Taking a quick look... it appears the only way rpc.mountd
will read /etc/mtab is if the 'crossmnt' export flag is 
set. Is this the case?

> 
> What would be needed to debug and optimise this?
Maybe reorder you exports so the 'hot' file systems are on the
top of the list...

> Could someone point me to the code that is involved in doing this?
utils/mountd/cache.c:nfsd_fh():path = next_mnt(&mnt, exp->m_export.e_path);

steved.


