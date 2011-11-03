Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm17-vm0.bullet.mail.ird.yahoo.com ([77.238.189.214]:39320 "HELO
	nm17-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751873Ab1KCVhX convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 17:37:23 -0400
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>
Message-ID: <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com>
Date: Thu, 3 Nov 2011 21:37:21 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Chuck Lever <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Nov 3, 2011, at 5:11 PM, Jim Rees wrote:

> 
>>  Trond Myklebust wrote:
>> 
>>>  [ 442.666622] NFS: failed to create MNT RPC client, status=-60
>>>  [ 442.666732] NFS: unable to mount server 137.226.167.241, error -60
>>>  [ 442.666868] VFS: Unable to mount root fs via NFS, trying floppy.
>>>  [ 442.667032] VFS: Insert root floppy and press ENTER
>>> 
>>   Error 60 is ETIMEDOUT on SPARC, so it seems that the problem is
>>   basically the same one that you see in your 2.6.32 trace (rpcbind:
>>   server 137.226.167.241 not responding, timed out) except that now it is
>>   a fatal error.
>> 
>>   Any idea why the first RPC calls might be failing here? A switch
>>   misconfiguration or something like that perhaps?
>> 
>>  Wasn't there a change in the way nfs mount options are handled by the 
> kernel
>>  for nfsroot about the time of 2.6.39?  Something about changing from 
> default
>>  udp to tcp maybe?
> 
> There was a change, but it was changed back to UDP because of problems like 
> this.  Behavior in 3.0 or the latest 2.6.39 stable kernel may be improved.
> 

I don't know if this was a tip to test newest 2.6.39 but as I wrote in my first email
 http://thread.gmane.org/gmane.linux.nfs/44596
that's the output of linux-2.6.39.4 with "nfsdebug":

[ 407.571521] IP-Config: Complete:
[ 407.571589] device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
[ 407.571793] host=cluster2, domain=, nis-domain=(none),
[ 407.571907] bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[ 407.572332] Root-NFS: nfsroot=/srv/nfs/cluster2
[ 407.572726] NFS: nfs mount opts='udp,nolock,addr=137.226.167.241'
[ 407.572927] NFS: parsing nfs mount option 'udp'
[ 407.572995] NFS: parsing nfs mount option 'nolock'
[ 407.573071] NFS: parsing nfs mount option 'addr=137.226.167.241'
[ 407.573139] NFS: MNTPATH: '/srv/nfs/cluster2'
[ 407.573203] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[ 408.617894] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[ 408.638319] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[ 442.666622] NFS: failed to create MNT RPC client, status=-60
[ 442.666732] NFS: unable to mount server 137.226.167.241, error -60
[ 442.666868] VFS: Unable to mount root fs via NFS, trying floppy.
[ 442.667032] VFS: Insert root floppy and press ENTER

And this behaviour is exactly the same as in all other 2.6.37 - 2.6.39.4 which I've tested.
So if anybody of you all have an idea what I could try to do, I'll follow...

Regards,
Lukas
