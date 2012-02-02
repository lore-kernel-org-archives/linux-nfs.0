Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:52021 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab2BBJFI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2012 04:05:08 -0500
Message-ID: <4F2A51BB.4050409@itwm.fraunhofer.de>
Date: Thu, 02 Feb 2012 10:04:59 +0100
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: Andrea Arcangeli <aarcange@redhat.com>
CC: James Bottomley <James.Bottomley@HansenPartnership.com>,
        Bernd Schubert <bernd.schubert@fastmail.fm>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>,
        Gregory Farnum <gregory.farnum@dreamhost.com>,
        lsf-pc@lists.linux-foundation.org,
        Chris Mason <chris.mason@oracle.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] end-to-end data and metadata corruption
 detection
References: <yq1k44e1pn6.fsf@sermon.lab.mkp.net> <4F217F0C.6030105@itwm.fraunhofer.de> <yq1y5sovcyw.fsf@sermon.lab.mkp.net> <4F283F7A.4020905@itwm.fraunhofer.de> <CAF3hT9AgVpcZkGLkr4EH4x4heNFgxNykM4Mp3V_C-RBSwJh7mA@mail.gmail.com> <20120201164521.GY16796@shiny> <1328115175.2768.11.camel@dabdike.int.hansenpartnership.com> <20120201174131.GD16796@shiny> <4F297D90.1010509@fastmail.fm> <1328120165.2768.39.camel@dabdike.int.hansenpartnership.com> <20120201183054.GM31817@redhat.com>
In-Reply-To: <20120201183054.GM31817@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/01/2012 07:30 PM, Andrea Arcangeli wrote:
> On Wed, Feb 01, 2012 at 12:16:05PM -0600, James Bottomley wrote:
>> supplying protection information to user space isn't about the
>> application checking what's on disk .. there's automatic verification in
>> the chain to do that (both the HBA and the disk will check the
>> protection information on entry/exit and transfer).  Supplying
>> protection information to userspace is about checking nothing went wrong
>> in the handoff between the end of the DIF stack and the application.
>
> Not sure if I got this right, but keeping protection information for
> in-ram pagecache and exposing it to userland somehow, to me sounds a
> bit of overkill as a concept. Then you should want that for anonymous
> memory too. If you copy the pagecache to a malloc()ed buffer and
> verify pagecache was consistent, but then the buffer is corrupt by
> hardware bitflip or software bug, then what's the point. Besides if
> this is getting exposed to userland and it's not hidden in the kernel
> (FS/Storage layers), userland could code its own verification logic
> without much added complexity. With CRC in hardware on the CPU it
> doesn't sound like a big cost to do it fully in userland and then you
> could run it on anonymous memory too if you need and not be dependent
> on hardware or filesystem details (well other than a a cpuid check at
> startup).

I think the point for network file systems is that they can reuse the 
disk-checksum for network verification. So instead of calculating a 
checksum for network and disk, just use one for both. The checksum also 
is supposed to be cached in memory, as that avoids re-calculation for 
other clients.

1)
client-1: sends data and checksum

server: Receives those data and verifies the checksum -> network 
transfer was ok, sends data and checksum to disk

2)
client-2 ... client-N: Ask for those data

server:  send cached data and cached checksum

client-2 ... client-N: Receive data and verify checksum


So the hole point of caching checksums is to avoid the server needs to 
recalculate those for dozens of clients. Recalculating checksums simply 
does not scale with an increasing number of clients, which want to read 
data processed by another client.


Cheers,
Bernd

