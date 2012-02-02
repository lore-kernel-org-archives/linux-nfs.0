Return-Path: linux-nfs-owner@vger.kernel.org
Received: from to5email.gprs.rogers.com ([74.198.8.2]:33366 "EHLO
	to5email.gprs.rogers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176Ab2BBUIn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2012 15:08:43 -0500
References: <yq1y5sovcyw.fsf@sermon.lab.mkp.net> <4F283F7A.4020905@itwm.fraunhofer.de> <CAF3hT9AgVpcZkGLkr4EH4x4heNFgxNykM4Mp3V_C-RBSwJh7mA@mail.gmail.com> <20120201164521.GY16796@shiny> <1328115175.2768.11.camel@dabdike.int.hansenpartnership.com> <20120201174131.GD16796@shiny> <4F297D90.1010509@fastmail.fm> <1328120165.2768.39.camel@dabdike.int.hansenpartnership.com> <20120201183054.GM31817@redhat.com> <4F2A51BB.4050409@itwm.fraunhofer.de> <20120202192643.GC5873@redhat.com>
In-Reply-To: <20120202192643.GC5873@redhat.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <1921A1E2-6F64-4043-8C61-4A2C46DA8B1B@dilger.ca>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Bernd Schubert <bernd.schubert@fastmail.fm>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Gregory Farnum <gregory.farnum@dreamhost.com>,
        "lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>,
        ChrisMason <chris.mason@oracle.com>
From: Andreas Dilger <adilger@dilger.ca>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] end-to-end data and metadata corruption detection
Date: Thu, 2 Feb 2012 12:46:55 -0700
To: Andrea Arcangeli <aarcange@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-02-02, at 12:26, Andrea Arcangeli <aarcange@redhat.com> wrote:

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
>> server: Receives those data and verifies the checksum -> network 
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

For servers, and clients to a lesser extent, the data may reside in cache for a long time. I agree that in many cases the data will be used immediately after the kernel verifies the data checksum from disk, but for long-lived data the change of accidental corruption (bit flip, bad pointer, other software bug) increases.

For our own checksum implementation in Lustre, we are planning to keep the checksum attached to the pages in cache on both the client and server, along with a "last checked" time, and periodically revalidate the in-memory checksum.

As Bernd states, this dramatically reduces the checksum overhead on the server, and avoids duplicate checksum calculations for the disk and network transfers if the same algorithms can be used for both. 

Cheers, Andreas