Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:46874 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab1KDBGp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 21:06:45 -0400
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>
Date: Thu, 3 Nov 2011 21:06:28 -0400
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>
To: Lukas Razik <linux@razik.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 3, 2011, at 7:09 PM, Lukas Razik wrote:

> 
> 
> Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> 
>> On Nov 3, 2011, at 5:37 PM, Lukas Razik wrote:
>> 
>>>> On Nov 3, 2011, at 5:11 PM, Jim Rees wrote:
>>> 
>>>> 
>>>>> Trond Myklebust wrote:
>>>>> 
>>>>>> [ 442.666622] NFS: failed to create MNT RPC client, status=-60
>>>>>> [ 442.666732] NFS: unable to mount server 137.226.167.241, 
>> error -60
>>>>>> [ 442.666868] VFS: Unable to mount root fs via NFS, trying 
>> floppy.
>>>>>> [ 442.667032] VFS: Insert root floppy and press ENTER
>>>>>> 
>>>>>    Error 60 is ETIMEDOUT on SPARC, so it seems that the problem is
>>>>>    basically the same one that you see in your 2.6.32 trace 
>> (rpcbind:
>>>>>    server 137.226.167.241 not responding, timed out) except that now 
>> it is
>>>>>    a fatal error.
>>>>> 
>>>>>    Any idea why the first RPC calls might be failing here? A switch
>>>>>    misconfiguration or something like that perhaps?
>>>>> 
>>>>> Wasn't there a change in the way nfs mount options are handled 
>> by the 
>>>> kernel
>>>>> for nfsroot about the time of 2.6.39?  Something about changing 
>> from 
>>>> default
>>>>> udp to tcp maybe?
>>>> 
>>>> There was a change, but it was changed back to UDP because of problems 
>> like 
>>>> this.  Behavior in 3.0 or the latest 2.6.39 stable kernel may be 
>> improved.
>>>> 
>>> 
>>> I don't know if this was a tip to test newest 2.6.39 but as I wrote in 
>> my first email
>>>   http://thread.gmane.org/gmane.linux.nfs/44596
>>> that's the output of linux-2.6.39.4 with "nfsdebug":
>>> 
>>> [ 407.571521] IP-Config: Complete:
>>> [ 407.571589] device=eth0, addr=137.226.167.242, mask=255.255.255.224, 
>> gw=137.226.167.225,
>>> [ 407.571793] host=cluster2, domain=, nis-domain=(none),
>>> [ 407.571907] bootserver=255.255.255.255, rootserver=137.226.167.241, 
>> rootpath=
>>> [ 407.572332] Root-NFS: nfsroot=/srv/nfs/cluster2
>>> [ 407.572726] NFS: nfs mount opts='udp,nolock,addr=137.226.167.241'
>>> [ 407.572927] NFS: parsing nfs mount option 'udp'
>>> [ 407.572995] NFS: parsing nfs mount option 'nolock'
>>> [ 407.573071] NFS: parsing nfs mount option 'addr=137.226.167.241'
>>> [ 407.573139] NFS: MNTPATH: '/srv/nfs/cluster2'
>>> [ 407.573203] NFS: sending MNT request for 
>> 137.226.167.241:/srv/nfs/cluster2
>>> [ 408.617894] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
>> Control: Rx
>>> [ 408.638319] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>>> [ 442.666622] NFS: failed to create MNT RPC client, status=-60
>>> [ 442.666732] NFS: unable to mount server 137.226.167.241, error -60
>>> [ 442.666868] VFS: Unable to mount root fs via NFS, trying floppy.
>>> [ 442.667032] VFS: Insert root floppy and press ENTER
>>> 
>>> And this behaviour is exactly the same as in all other 2.6.37 - 2.6.39.4 
>> which I've tested.
>>> So if anybody of you all have an idea what I could try to do, I'll 
>> follow...
>> 
>> Find out why the very first RPC on your system always fails.  As Trond says, the 
>> only reason this worked on the older kernels is because NFSROOT fell back to a 
>> default port for NFSD.  This is also broken behavior, but in your case it 
>> happened to work so you never noticed it.
>> 
>> I seem to recall there's a way to set the NFS and RPC debugging flags on the 
>> kernel command line so more information can be captured during boot.  But I 
>> don't see it under Documentation/.
>> 
>> You could add a line in fs/nfs/nfsroot.c:nfs_root_debug() to set flags also in 
>> the rpc_debug global variable to gather more information.
>> 
> 
> OK
> I've watched wireshark on cluster1 during start up of cluster2 (with linux-2.6.32) which first tries 10003 and then 10005.
> The result is that cluster1 doesn't get a datagram for port 10003:
> http://net.razik.de/linux/T5120/cluster2_NFSROOT_MOUNT.png
> 
> The first ARP request in the screenshot came _after_ the <tag> in this kernel log:
> [ 6492.807917] IP-Config: Complete:
> [ 6492.807978]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
> [ 6492.808227]      host=cluster2, domain=, nis-domain=(none),
> [ 6492.808312]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
> [ 6492.808570] Looking up port of RPC 100003/2 on 137.226.167.241
> [ 6493.886014] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
> [ 6493.905840] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> <tag>
> [ 6527.827055] rpcbind: server 137.226.167.241 not responding, timed out
> [ 6527.827237] Root-NFS: Unable to get nfsd port number from server, using default
> [ 6527.827353] Looking up port of RPC 100005/1 on 137.226.167.241
> [ 6527.842212] VFS: Mounted root (nfs filesystem) on device 0:15.
> 
> 
> So I don't think that it's a problem of the hardware between the machines.
> There's no reason why I wouldn't see an ARP requests from cluster2 which would have been sent _before_ the <tag> if there would be one. I think: cluster2 never sends a request to port 10003.
> What do you think?

It agrees with our initial assessment that the first RPC request is failing.  The RPC client never gets the request through cluster2's network stack because the NIC hasn't re-initialized when the request is sent.

It looks like your system does a PXE boot, which provides the IP configuration shown above.  But then the kernel resets the NIC.  During that reset, the kernel is attempting to contact the NFS server to mount the root file system.

We've set up NFSROOT to use UDP so that it will be relatively immune to these initialization order problems.  The RPC client should be retrying the lost request, but apparently it isn't.  What if you added "retrans=10" to cluster2's mount options?  (on the chance that mount option setting would be copied to the rpcbind client's RPC transport...)

IMO the correct way to fix this is to provide proper serialization in the networking layer so that RPC requests are not even attempted until the NIC is ready to carry traffic.  That may be a pipe dream though.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




