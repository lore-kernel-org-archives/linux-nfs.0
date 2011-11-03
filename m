Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:43919 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab1KCVLA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 17:11:00 -0400
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1320353685.18396.119.camel@lade.trondhjem.org>
Date: Thu, 3 Nov 2011 17:10:39 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FBED9B6A-6096-4ADE-9BEB-DF536FD5A5A2@oracle.com>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Lukas Razik <linux@razik.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 3, 2011, at 4:54 PM, Trond Myklebust wrote:

> On Thu, 2011-11-03 at 19:43 +0000, Lukas Razik wrote: 
>> Hello together!
>> 
>> My OS: Debian 6.0.3 (squeeze)
>> Machines: SUN Enterprise T5120 (USPARC64)
>> ---
>> Issue description:
>> 
>> I've an NFS
>> server (cluster1=137.226.167.241) and a
>> client (cluster2=137.226.167.242) which should mount it's nfsroot from cluster1.
>> 
>> The linux-2.6.32 kernel on cluster2 shows this during startup:
>> [ 528.982985] IP-Config: Complete:
>> [ 528.983049] device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
>> [ 528.983299] host=cluster2, domain=, nis-domain=(none),
>> [ 528.983383] bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
>> [ 528.983633] Looking up port of RPC 100003/2 on 137.226.167.241
>> [ 530.037059] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
>> [ 530.056881] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>> [ 564.002113] rpcbind: server 137.226.167.241 not responding, timed out
>> [ 564.002295] Root-NFS: Unable to get nfsd port number from server, using default
>> [ 564.002412] Looking up port of RPC 100005/1 on 137.226.167.241
>> [ 564.104137] VFS: Mounted root (nfs filesystem) on device 0:15.
>> 
>> It can mount the nfsroot finally.
>> 
>> But if I use kernel linux-2.6.39.4 on cluster2 it can't mount it's nfsroot.
>> (I've added "nfsdebug" to the kernel arguments for more debug info):
>> [ 407.571521] IP-Config: Complete:
>> [ 407.571589] device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
>> [ 407.571793] host=cluster2, domain=, nis-domain=(none),
>> [ 407.571907] bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
>> [ 407.572332] Root-NFS: nfsroot=/srv/nfs/cluster2
>> [ 407.572726] NFS: nfs mount opts='udp,nolock,addr=137.226.167.241'
>> [ 407.572927] NFS: parsing nfs mount option 'udp'
>> [ 407.572995] NFS: parsing nfs mount option 'nolock'
>> [ 407.573071] NFS: parsing nfs mount option 'addr=137.226.167.241'
>> [ 407.573139] NFS: MNTPATH: '/srv/nfs/cluster2'
>> [ 407.573203] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
>> [ 408.617894] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
>> [ 408.638319] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>> [ 442.666622] NFS: failed to create MNT RPC client, status=-60
>> [ 442.666732] NFS: unable to mount server 137.226.167.241, error -60
>> [ 442.666868] VFS: Unable to mount root fs via NFS, trying floppy.
>> [ 442.667032] VFS: Insert root floppy and press ENTER
>> 
> Error 60 is ETIMEDOUT on SPARC, so it seems that the problem is
> basically the same one that you see in your 2.6.32 trace (rpcbind:
> server 137.226.167.241 not responding, timed out) except that now it is
> a fatal error.
> 
> Any idea why the first RPC calls might be failing here? A switch
> misconfiguration or something like that perhaps?

Yeah, I'm not clear how the system can do kernel IP configuration with the NIC not yet initialized.

In any event, these RPC requests are supposed to be over UDP, and they should be retransmitted, making the timing of NIC readiness immaterial.  That's the design, anyway.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




