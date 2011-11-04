Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm10.bullet.mail.ird.yahoo.com ([77.238.189.39]:36602 "HELO
	nm10.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752871Ab1KDJoU convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 05:44:20 -0400
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
Message-ID: <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
Date: Fri, 4 Nov 2011 09:44:18 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>  OK

>>  I've watched wireshark on cluster1 during start up of cluster2 (with 
> linux-2.6.32) which first tries 10003 and then 10005.
>>  The result is that cluster1 doesn't get a datagram for port 10003:
>>  http://net.razik.de/linux/T5120/cluster2_NFSROOT_MOUNT.png
>> 
>>  The first ARP request in the screenshot came _after_ the <tag> in 
> this kernel log:
>>  [ 6492.807917] IP-Config: Complete:
>>  [ 6492.807978]      device=eth0, addr=137.226.167.242, 
> mask=255.255.255.224, gw=137.226.167.225,
>>  [ 6492.808227]      host=cluster2, domain=, nis-domain=(none),
>>  [ 6492.808312]      bootserver=255.255.255.255, rootserver=137.226.167.241, 
> rootpath=
>>  [ 6492.808570] Looking up port of RPC 100003/2 on 137.226.167.241
>>  [ 6493.886014] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
> Control: Rx
>>  [ 6493.905840] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>>  <tag>
>>  [ 6527.827055] rpcbind: server 137.226.167.241 not responding, timed out
>>  [ 6527.827237] Root-NFS: Unable to get nfsd port number from server, using 
> default
>>  [ 6527.827353] Looking up port of RPC 100005/1 on 137.226.167.241
>>  [ 6527.842212] VFS: Mounted root (nfs filesystem) on device 0:15.
>> 
>> 
>>  So I don't think that it's a problem of the hardware between the 
> machines.
>>  There's no reason why I wouldn't see an ARP requests from cluster2 
> which would have been sent _before_ the <tag> if there would be one. I 
> think: cluster2 never sends a request to port 10003.
>>  What do you think?
> 
> It agrees with our initial assessment that the first RPC request is failing.  
> The RPC client never gets the request through cluster2's network stack 
> because the NIC hasn't re-initialized when the request is sent.
> 
> It looks like your system does a PXE boot, which provides the IP configuration 
> shown above.  But then the kernel resets the NIC.  During that reset, the kernel 
> is attempting to contact the NFS server to mount the root file system.
> 
> We've set up NFSROOT to use UDP so that it will be relatively immune to 
> these initialization order problems.  The RPC client should be retrying the lost 
> request, but apparently it isn't.  What if you added "retrans=10" 
> to cluster2's mount options?  (on the chance that mount option setting would 
> be copied to the rpcbind client's RPC transport...)
> 
> IMO the correct way to fix this is to provide proper serialization in the 
> networking layer so that RPC requests are not even attempted until the NIC is 
> ready to carry traffic.  That may be a pipe dream though.
> 

I thank you three very much for your help! Now I'm sure that I haven't misconfigured anything...
But I don't see a work around to get the NFSROOT mounted during start up of a kernel >=2.6.37 .
It would be very sad with these nice Oracle (SUN) machines if no one could use them because of this bug.

Do you know a kernel developer who maybe would try to write a patch for this problem?
Or do you have another idea what I could do?

Regards,
Lukas
