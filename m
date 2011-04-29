Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7350 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759698Ab1D2QyV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2011 12:54:21 -0400
Subject: Re: Linux to Netapp -> Is UDP over WAN safe as long as I use
 "sync, hard and intr" ?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David McGiven <davidmcgivenn@gmail.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <6FF9D79F-27E7-49E5-AE4D-A5A17C8F1403@gmail.com>
References: <D158BE8E-BEDC-43EF-9C6C-48668AA6F5DF@gmail.com>
	 <20AFBC51-7103-47E9-825A-A52B4FCA08B6@oracle.com>
	 <6FF9D79F-27E7-49E5-AE4D-A5A17C8F1403@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Apr 2011 12:54:04 -0400
Message-ID: <1304096044.3654.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-04-29 at 17:52 +0200, David McGiven wrote:
> Chuck,
> 
> Thank you very much for the advice. I'm currently using wsize and  
> rsize of 1024 to avoid IP fragmentation. Strangely, UDP performs much  
> faster compared to TCP, no matter the size of rsize/wsize. I am  
> puzzled about that, but ...
> 
> The problem with the network troubleshoot is that I cannot change  
> anything in the path between the client and the server : 2 routers and  
> a CISCO PIX (I don't know if it's one of this 2 hops or it's  
> invisible, but it's there for sure). While researching this problem  
> I've noticed that iperf shows extremely slow speed from client to  
> server LAN segments, while in the opposite way the speed is ok.  
> There's definitely something wrong there but I cannot change it  
> neither complain, so, let UDP be it, I'm satisfied enough with the  
> speed I get with rsize/wsize=1024. My main concern was about data  
> corruption.

Have you checked the autonegotiation settings on your NIC? 'ethtool
eth0' is your friend...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

