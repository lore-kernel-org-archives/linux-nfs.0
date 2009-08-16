From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 00/11] nfs-utils: add TIRPC/IPv6 support to rpc.nfsd
Date: Sun, 16 Aug 2009 16:06:13 -0400
Message-ID: <4A8866B5.8090008@RedHat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60700 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754958AbZHPUGR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Aug 2009 16:06:17 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n7GK6J66024465
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2009 16:06:19 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n7GK6In2006645
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2009 16:06:18 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-26.bos.redhat.com [10.16.10.26])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n7GK6HUp011333
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2009 16:06:17 -0400
In-Reply-To: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/08/2009 02:00 PM, Jeff Layton wrote:
> This is the sixth attempt at a patchset to add TIRPC and IPv6 support to
> the rpc.nfsd program. The significant differences from the last set are:
> 
> 1) Change it to log errors to stderr by default, and add a --syslog
> switch to force output to syslog
> 
> 2) moved nfssvc.c into the nfsd directory (and out of libnfs.a).
> rpc.nfsd is the only user of those routines so there's no need to
> keep it in common code.
> 
> 3) declared a common static string buffer for the nfssvc routines
> to use to cut down stack usage. It's also smaller than BUFSIZ so the
> general memory footprint for rpc.nfsd should be smaller.
> 
> There are also a number of cleanups and small fixes.
> 
> Comments and suggestions appreciated...
> 
> Jeff Layton (11):
>   nfs-utils: move nfssvc.c to nfsd dir and clean up linking of nfsd
>   nfs-utils: clean up option parsing in nfsd.c
>   nfs-utils: convert rpc.nfsd to use xlog()
>   nfs-utils: clean up NFSCTL_* macros for handling protocol bits
>   nfs-utils: declare a static common buffer for nfssvc.c routines
>   nfs-utils: move check for active knfsd to helper function
>   nfs-utils: convert nfssvc_setfds to use getaddrinfo
>   nfs-utils: break up the nfssvc interface
>   nfs-utils: add IPv6 support to nfssvc_setfds
>   nfs-utils: add IPv6 support to nfsd
>   nfs-utils: update the nfsd manpage and copyright notices

Committed.... 

steved.
