Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:49911 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171Ab1KDNya convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 09:54:30 -0400
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
Date: Fri, 4 Nov 2011 09:54:06 -0400
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
To: Lukas Razik <linux@razik.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2011, at 5:44 AM, Lukas Razik wrote:

>>> OK
> 
>>> I've watched wireshark on cluster1 during start up of cluster2 (with 
>> linux-2.6.32) which first tries 10003 and then 10005.
>>> The result is that cluster1 doesn't get a datagram for port 10003:
>>> http://net.razik.de/linux/T5120/cluster2_NFSROOT_MOUNT.png
>>> 
>>> The first ARP request in the screenshot came _after_ the <tag> in 
>> this kernel log:
>>> [ 6492.807917] IP-Config: Complete:
>>> [ 6492.807978]      device=eth0, addr=137.226.167.242, 
>> mask=255.255.255.224, gw=137.226.167.225,
>>> [ 6492.808227]      host=cluster2, domain=, nis-domain=(none),
>>> [ 6492.808312]      bootserver=255.255.255.255, rootserver=137.226.167.241, 
>> rootpath=
>>> [ 6492.808570] Looking up port of RPC 100003/2 on 137.226.167.241
>>> [ 6493.886014] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
>> Control: Rx
>>> [ 6493.905840] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>>> <tag>
>>> [ 6527.827055] rpcbind: server 137.226.167.241 not responding, timed out
>>> [ 6527.827237] Root-NFS: Unable to get nfsd port number from server, using 
>> default
>>> [ 6527.827353] Looking up port of RPC 100005/1 on 137.226.167.241
>>> [ 6527.842212] VFS: Mounted root (nfs filesystem) on device 0:15.
>>> 
>>> 
>>> So I don't think that it's a problem of the hardware between the 
>> machines.
>>> There's no reason why I wouldn't see an ARP requests from cluster2 
>> which would have been sent _before_ the <tag> if there would be one. I 
>> think: cluster2 never sends a request to port 10003.
>>> What do you think?
>> 
>> It agrees with our initial assessment that the first RPC request is failing.  
>> The RPC client never gets the request through cluster2's network stack 
>> because the NIC hasn't re-initialized when the request is sent.
>> 
>> It looks like your system does a PXE boot, which provides the IP configuration 
>> shown above.  But then the kernel resets the NIC.  During that reset, the kernel 
>> is attempting to contact the NFS server to mount the root file system.
>> 
>> We've set up NFSROOT to use UDP so that it will be relatively immune to 
>> these initialization order problems.  The RPC client should be retrying the lost 
>> request, but apparently it isn't.  What if you added "retrans=10" 
>> to cluster2's mount options?  (on the chance that mount option setting would 
>> be copied to the rpcbind client's RPC transport...)
>> 
>> IMO the correct way to fix this is to provide proper serialization in the 
>> networking layer so that RPC requests are not even attempted until the NIC is 
>> ready to carry traffic.  That may be a pipe dream though.
>> 
> 
> I thank you three very much for your help! Now I'm sure that I haven't misconfigured anything...
> But I don't see a work around to get the NFSROOT mounted during start up of a kernel >=2.6.37 .
> It would be very sad with these nice Oracle (SUN) machines if no one could use them because of this bug.

If you boot via tftp, I bet this problem will go away because the network interface will be working by the time the NFSROOT mount is attempted.

The NFSROOT code assumes that if kernel IP configuration worked, then the NIC is already up.  That is clearly not the case if you boot from your local disk.

> Do you know a kernel developer who maybe would try to write a patch for this problem?
> Or do you have another idea what I could do?

As for a patch: no-one can write a patch unless we understand precisely why the first RPC fails.  I already explained how to add a line or two to fs/nfs/nfsroot.c to give us more information.  If you need a patch to do this, I can send one later today.

I might be able to reproduce it here, now that I understand your set up, but it would require building a partial NFSROOT environment.  I can't get to that until next week.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




