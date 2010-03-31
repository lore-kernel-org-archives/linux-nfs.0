Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:23438 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765Ab0CaOXJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Mar 2010 10:23:09 -0400
Message-ID: <4BB35A53.5000003@oracle.com>
Date: Wed, 31 Mar 2010 10:21:07 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Daniel J Blueman <daniel.blueman@gmail.com>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: [2.6.34-rc2 NFS4 oops] open error path failure...
References: <6278d2221003291136p6481fe8emfb039403343c082@mail.gmail.com>	 <20100329190307.GJ30031@ZenIV.linux.org.uk>	 <1269897740.15895.82.camel@localhost.localdomain> <w2s6278d2221003310420xd36fa9ey92b781fb9f4d1a10@mail.gmail.com>
In-Reply-To: <w2s6278d2221003310420xd36fa9ey92b781fb9f4d1a10@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/31/2010 07:20 AM, Daniel J Blueman wrote:
> Talking of expensive, I see latencytop show>16000ms latency for
> writing pages when I have a workload that does large buffered I/O to
> an otherwise uncongested server. The gigabit network is saturated, and
> reads often stall for 1000-4000ms (!). Client has the default 16 TCP
> request slots, and server has 8 nfsds - the server is far from disk or
> processor-saturated. I'll see if there is any useful debugging I can
> get about this.

That latency is pretty much guaranteed to be due to a long RPC backlog 
queue on the client.  Bumping the size of the slot table to 128 and 
increasing the number of NFSD threads may help.

-- 
chuck[dot]lever[at]oracle[dot]com
