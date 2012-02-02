Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:57878 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753973Ab2BBWwr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2012 17:52:47 -0500
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 84051214EC
	for <linux-nfs@vger.kernel.org>; Thu,  2 Feb 2012 17:52:46 -0500 (EST)
Message-ID: <4F2B13BA.1080804@itwm.fraunhofer.de>
Date: Thu, 02 Feb 2012 23:52:42 +0100
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: Andrea Arcangeli <aarcange@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Bernd Schubert <bernd.schubert@fastmail.fm>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Gregory Farnum <gregory.farnum@dreamhost.com>,
        lsf-pc@lists.linux-foundation.org,
        Chris Mason <chris.mason@oracle.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] end-to-end data and metadata corruption
 detection
References: <yq1y5sovcyw.fsf@sermon.lab.mkp.net> <4F283F7A.4020905@itwm.fraunhofer.de> <CAF3hT9AgVpcZkGLkr4EH4x4heNFgxNykM4Mp3V_C-RBSwJh7mA@mail.gmail.com> <20120201164521.GY16796@shiny> <1328115175.2768.11.camel@dabdike.int.hansenpartnership.com> <20120201174131.GD16796@shiny> <4F297D90.1010509@fastmail.fm> <1328120165.2768.39.camel@dabdike.int.hansenpartnership.com> <20120201183054.GM31817@redhat.com> <4F2A51BB.4050409@itwm.fraunhofer.de> <20120202192643.GC5873@redhat.com>
In-Reply-To: <20120202192643.GC5873@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/02/2012 08:26 PM, Andrea Arcangeli wrote:
> On Thu, Feb 02, 2012 at 10:04:59AM +0100, Bernd Schubert wrote:
>> I think the point for network file systems is that they can reuse the
>> disk-checksum for network verification. So instead of calculating a
>> checksum for network and disk, just use one for both. The checksum also
>> is supposed to be cached in memory, as that avoids re-calculation for
>> other clients.
>>
>> 1)
>> client-1: sends data and checksum
>>
>> server: Receives those data and verifies the checksum ->  network
>> transfer was ok, sends data and checksum to disk
>>
>> 2)
>> client-2 ... client-N: Ask for those data
>>
>> server:  send cached data and cached checksum
>>
>> client-2 ... client-N: Receive data and verify checksum
>>
>>
>> So the hole point of caching checksums is to avoid the server needs to
>> recalculate those for dozens of clients. Recalculating checksums simply
>> does not scale with an increasing number of clients, which want to read
>> data processed by another client.
>
> This makes sense indeed. My argument was only about the exposure of
> the storage hw format cksum to userland (through some new ioctl for
> further userland verification of the pagecache data in the client
> pagecache, done by whatever program is reading from the cache). The
> network fs client lives in kernel, the network fs server lives in
> kernel, so no need to expose the cksum to userland to do what you
> described above.
>
> I meant if we can't trust the pagecache to be correct (after the
> network fs client code already checked the cksum cached by the server
> and sent to the client along the server cached data), I don't see much
> value added through a further verification by the userland program
> running on the client and accessing pagecache in the client. If we
> can't trust client pagecache to be safe against memory bitflips or
> software bugs, we can hardly trust the anonymous memory too.

Well, now it gets a bit troublesome - not all file systems are in kernel 
space. FhGFS uses kernel clients, but has user space daemons. I think 
Ceph does it similarly. And although I'm not sure about the roadmap of 
Gluster and if data verification is planned at all, but if it would like 
to do that, even the clients would need get access to the checksums in 
user space.

Now lets assume we ignore user space clients for now, what about using 
the splice interface to also send checksums? So as basic concept file 
systems servers are not interested at all about the real data, but only 
do the management between disk and network. So a possible solution to 
not expose checksums to user space daemons is to simply not expose data 
to the servers at all. However, in that case the server side kernel 
would need to do the checksum verification, so even for user space daemons.
Remaining issue with splice is that splice does not work with 
inifiniband-ibverbs due to the missing socket fd.

Another solution that also might work is to expose checksums only 
read-only to user space.



Cheers,
Bernd
