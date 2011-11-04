Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm16.bullet.mail.ird.yahoo.com ([77.238.189.69]:25435 "HELO
	nm16.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750975Ab1KDXRY convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 19:17:24 -0400
References: <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com> <20111104132050.GB13788@umich.edu> <01668DEE-43F7-464B-9BCF-6E52DF0B5956@oracle.com> <20111104144617.GB911@umich.edu> <1320421602.96030.YahooMailNeo@web24707.mail.ird.yahoo.com> <85479822-C31D-450A-A361-046A0E920F3D@oracle.com>
Message-ID: <1320448642.66490.YahooMailNeo@web24705.mail.ird.yahoo.com>
Date: Fri, 4 Nov 2011 23:17:22 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <85479822-C31D-450A-A361-046A0E920F3D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>  [11140.867895] NFS:   parsing nfs mount option 'retrans=10'

>>  [11140.867946] NFS:   parsing nfs mount option 'timeo=60'
>>  [11140.867996] NFS:   parsing nfs mount option 'nolock'
>>  [11140.868043] NFS:   parsing nfs mount option 
> 'addr=137.226.167.241'
>>  [11140.868106] NFS: MNTPATH: '/srv/nfs/cluster2'
>>  [11140.868142] NFS: sending MNT request for 
> 137.226.167.241:/srv/nfs/cluster2
>>  [11141.912761] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
> Control: Rx
>>  [11141.933177] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>>  [11143.873095] NFS: failed to create MNT RPC client, status=-65
>>  [11143.873205] NFS: unable to mount server 137.226.167.241, error -65
> 
> You got a different result: -65 is EHOSTUNREACH.  And actually, I would have 
> expected that error from the UDP case as well.
> 

Oh, sorry! I thought it wouldn't have used the option...
Thanks for this hint!

But I've another important fact:
I've tested linux-3.1 and the behaviour is the same as in linux-2.6.39.4 with the difference that eth0 seems to be up when NFS tries to mount NFSROOT. So I see no reason why the kernel can't send the mount request (I see no request in wireshark).

So now I'll enable more debug output in 3.1 and send you the result like I've done it in my last email for 2.6.39.4...
