Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754008Ab2BATPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Feb 2012 14:15:55 -0500
Date: Wed, 1 Feb 2012 19:30:54 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Bernd Schubert <bernd.schubert@fastmail.fm>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>,
        Gregory Farnum <gregory.farnum@dreamhost.com>,
        lsf-pc@lists.linux-foundation.org,
        Chris Mason <chris.mason@oracle.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] end-to-end data and metadata corruption
 detection
Message-ID: <20120201183054.GM31817@redhat.com>
References: <yq1k44e1pn6.fsf@sermon.lab.mkp.net>
 <4F217F0C.6030105@itwm.fraunhofer.de>
 <yq1y5sovcyw.fsf@sermon.lab.mkp.net>
 <4F283F7A.4020905@itwm.fraunhofer.de>
 <CAF3hT9AgVpcZkGLkr4EH4x4heNFgxNykM4Mp3V_C-RBSwJh7mA@mail.gmail.com>
 <20120201164521.GY16796@shiny>
 <1328115175.2768.11.camel@dabdike.int.hansenpartnership.com>
 <20120201174131.GD16796@shiny>
 <4F297D90.1010509@fastmail.fm>
 <1328120165.2768.39.camel@dabdike.int.hansenpartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1328120165.2768.39.camel@dabdike.int.hansenpartnership.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 01, 2012 at 12:16:05PM -0600, James Bottomley wrote:
> supplying protection information to user space isn't about the
> application checking what's on disk .. there's automatic verification in
> the chain to do that (both the HBA and the disk will check the
> protection information on entry/exit and transfer).  Supplying
> protection information to userspace is about checking nothing went wrong
> in the handoff between the end of the DIF stack and the application.

Not sure if I got this right, but keeping protection information for
in-ram pagecache and exposing it to userland somehow, to me sounds a
bit of overkill as a concept. Then you should want that for anonymous
memory too. If you copy the pagecache to a malloc()ed buffer and
verify pagecache was consistent, but then the buffer is corrupt by
hardware bitflip or software bug, then what's the point. Besides if
this is getting exposed to userland and it's not hidden in the kernel
(FS/Storage layers), userland could code its own verification logic
without much added complexity. With CRC in hardware on the CPU it
doesn't sound like a big cost to do it fully in userland and then you
could run it on anonymous memory too if you need and not be dependent
on hardware or filesystem details (well other than a a cpuid check at
startup).
