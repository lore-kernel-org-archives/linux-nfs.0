From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] nfs_statfs: statfs error = 512 ?
Date: Wed, 23 Jan 2008 11:21:48 -0500
Message-ID: <4797699C.2020100@RedHat.com>
References: <479763EC.3090601@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Sev Binello <sev-IGkKxAqZmp0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:42083 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbYAWQWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2008 11:22:13 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JHiMc-0007Hj-KF
	for linux-nfs@vger.kernel.org; Thu, 24 Jan 2008 03:22:10 +1100
In-Reply-To: <479763EC.3090601-IGkKxAqZmp0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Sev Binello wrote:
> Hi -
> 
>   Can anyone explain the following error message...
> 
>          Jan 22 11:03:28 acnmcr5s kernel: nfs_statfs: statfs error = 512
> 
>     We seem to be getting it way too frequently,
>     and was wondering if it was correlated to systems becoming 
> unresponsive at times.
>    
>      Out clients are running 2.6.9-55.0.9.ELsmp, Redhat WS4 U5
>      while nfs servers are still at  2.4.21-47.ELsmp Rhat WS 3 U8
>      We are using UDP.
I *think* do recognize this problem... I believe it has to do
with the fact the mount command can not talk to either the NFS
server or the server daemons mountd or portmapper. 

I also believe this problem has been fixed later kernels, but
that fix may not have made it into RHEL 3...

steved.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

