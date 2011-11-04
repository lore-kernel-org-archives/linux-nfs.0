Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm21.bullet.mail.ird.yahoo.com ([212.82.108.136]:22686 "HELO
	nm21.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751952Ab1KDPEb convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 11:04:31 -0400
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com> <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>
Message-ID: <1320418678.59917.YahooMailNeo@web24712.mail.ird.yahoo.com>
Date: Fri, 4 Nov 2011 14:57:58 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>  It would be very sad with these nice Oracle (SUN) machines if no one could 

> use them because of this bug.
> 
> If you boot via tftp, I bet this problem will go away because the network 
> interface will be working by the time the NFSROOT mount is attempted.

Yes this could be a workaround but there is another problem with boot via tftp (and OpenBoot) which another team member is trying to solve...


> The NFSROOT code assumes that if kernel IP configuration worked, then the NIC is 
> already up.  That is clearly not the case if you boot from your local disk.

Yes, that's surely not the standard way: To mount nfsroot although you have a local disk...


>>  Do you know a kernel developer who maybe would try to write a patch for 
> this problem?
>>  Or do you have another idea what I could do?
> 
> As for a patch: no-one can write a patch unless we understand precisely why the 
> first RPC fails.  I already explained how to add a line or two to 
> fs/nfs/nfsroot.c to give us more information.  If you need a patch to do this, I 
> can send one later today.
> 
> I might be able to reproduce it here, now that I understand your set up, but it 
> would require building a partial NFSROOT environment.  I can't get to that 
> until next week.
> 

If you have the time for the patch, it would be very nice! Otherwise I'll try it as soon as I can.
The problem is that the system should work as soon as possible. So it would be nice to have a work around.
In parallel, I'll give you all information I have and test all patches you give me as long as you all are interested.

So now I'm trying the proposed workaroundsand after that I'll try to add the lines you wrote about (ASAP)...

Regards,
Lukas
