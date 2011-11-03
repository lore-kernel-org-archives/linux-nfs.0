Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm12.bullet.mail.ird.yahoo.com ([77.238.189.65]:30872 "HELO
	nm12.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752739Ab1KCV66 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 17:58:58 -0400
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <1320355087.59657.YahooMailNeo@web24703.mail.ird.yahoo.com> <20111103213833.GA741@umich.edu>
Message-ID: <1320357535.9760.YahooMailNeo@web24708.mail.ird.yahoo.com>
Date: Thu, 3 Nov 2011 21:58:55 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Jim Rees <rees@umich.edu>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20111103213833.GA741@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Lukas Razik wrote:

> 
>   The next thing is:
>   Really all working kernels (<=2.6.36.4) first output
>    Looking up port of RPC 100003/2 on 137.226.167.241
>   then
>    Looking up port of RPC 100005/1 on 137.226.167.241
>   and then the mount is successful
>    VFS: Mounted root (nfs filesystem) on device 0:15.
>   
>   So what about >=2.6.37?
>   Why don't these kernels try other ports, too?
>   Or why do the old kernels try more than one port?
>   Why is there no output (even in the nfsdebug mode) that the kernel tries to 
> connect to the RPC service?
>   Is there a "easy" possibility to change port 100003 to 100005 in 
>> =2.6.37?
> 
> Those are the rpc numbers.  The kernel is trying to find the port numbers
> for those services.  100003 is nfs, 100005 is mount.
> I guess at this point
> I would use wireshark to find out what requests are actually being made and
> responded to in both cases.  Are you sure portmap is working on the server
> and not being blocked by a firewall?
>

When I boot from hard disk and try to mount the same exports from cluster1 on cluster2 by
# mount -t nfs cluster1:[...]
then it works immediately and without errors.

There's no firewall. But I've done a test to check it:
---
root@cluster2:~# telnet cluster1 111
Trying 137.226.167.241...
Connected to 137.226.167.241.
Escape character is '^]'.
TEST
TEST
Connection closed by foreign host.
---
So it's no problem to connect to the portmapper of cluster1 from cluster2.
