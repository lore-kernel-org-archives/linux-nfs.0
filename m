Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53560 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754094Ab2BVRZL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Feb 2012 12:25:11 -0500
Date: Wed, 22 Feb 2012 12:25:10 -0500
To: Fu Liankun <fuliankun@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: spnfs write performance issue
Message-ID: <20120222172510.GA12708@fieldses.org>
References: <4F44C071.8010104@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F44C071.8010104@cn.fujitsu.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 22, 2012 at 06:16:17PM +0800, Fu Liankun wrote:
> When copy a big file(about 500MB) to nfs server using pnfs, it cost
> obvious longer time as compared with NFSv3 or NFSv4 protocol.
> 
> PNFS cost about 300-550s
> NFSv3 cost about 49s
> NFSv4 cost about 49s
> 
> My test environment as following:
> 
> MDS: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.100, ipaddr2:192.168.1.100
> DS1: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.101, ipaddr2:192.168.1.101
> DS2: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.102, ipaddr2:192.168.1.102
> client: RHEL6.2GA(2.6.32-220.el6.i686)    ipaddr1: 192.168.0.19,

What kind of server are you using?

--b.

> ipaddr2:192.168.1.19
> 
> 192.168.1.100 <-------- NFS4.1 connection --------->192.168.1.101
> 192.168.0.100 <-------- NFS4.1 connection --------->192.168.0.102
> 192.168.0.19  <-------- NFS4.1 connection --------->192.168.0.100
> 
> Dunring the write process, the client output the message:
> FS-Cache: Loaded
> FS-Cache: Netfs 'nfs' registered for caching
> nfs4filelayout_init: NFSv4 File Layout Driver Registering...
> nfs: server 192.168.1.101 not responding, timed out
> 
> The message "nfs: server 192.168.1.101 not responding, timed out" was
> output during the COMMIT request.
> 
> Who can tell me the reason why pnfs cost so long time.
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
