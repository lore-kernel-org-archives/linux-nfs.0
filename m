Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:62035 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789Ab2BASP2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 13:15:28 -0500
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Chris Mason <chris.mason@oracle.com>,
        Gregory Farnum <gregory.farnum@dreamhost.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        lsf-pc@lists.linux-foundation.org
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] end-to-end data and metadata corruption detection
From: "Martin K. Petersen" <martin.petersen@oracle.com>
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com>
	<4F2147BA.6030607@itwm.fraunhofer.de>
	<yq1k44e1pn6.fsf@sermon.lab.mkp.net>
	<4F217F0C.6030105@itwm.fraunhofer.de>
	<yq1y5sovcyw.fsf@sermon.lab.mkp.net>
	<4F283F7A.4020905@itwm.fraunhofer.de>
	<CAF3hT9AgVpcZkGLkr4EH4x4heNFgxNykM4Mp3V_C-RBSwJh7mA@mail.gmail.com>
	<20120201164521.GY16796@shiny>
	<1328115175.2768.11.camel@dabdike.int.hansenpartnership.com>
Date: Wed, 01 Feb 2012 13:15:14 -0500
In-Reply-To: <1328115175.2768.11.camel@dabdike.int.hansenpartnership.com>
	(James Bottomley's message of "Wed, 01 Feb 2012 10:52:55 -0600")
Message-ID: <yq1d39ys9n1.fsf@sermon.lab.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "James" == James Bottomley <James.Bottomley@HansenPartnership.com> writes:

James> I broadly agree with this, but even if you do sync writes and
James> cache read only copies, we still have the problem of how we do
James> the read side verification of DIX.  

Whoever requested the protected information will know how to verify
it.

Right now, if the Oracle DB enables a protected transfer, it'll do a
verification pass once a read I/O completes.

Similarly, the block layer will verify data+PI if the auto-protection
feature has been turned on.


James> In theory, when you read, you could either get the cached copy or
James> an actual read (which will supply protection information), so for
James> the cached copy we need to return cached protection information
James> implying that we need some way of actually caching it.

Let's assume we add a PI buffer to kaio. If an application wants to send
or receive PI it needs to sit on top of a filesystem that can act as a
conduit for PI. That filesystem will need to store the PI for each page
somewhere hanging off of its page private pointer.

When submitting a write the filesystem must iterate over these PI
buffers and generate a bio integrity payload that it an attach to the
data bio. This works exactly the same way as iterating over the data
pages to build the data portion of the bio.

When an application is requesting PI, the filesystem must allocate the
relevant memory and update its private data to reflect the PI buffers.
These buffers are then attached the same way as on a write. And when the
I/O completes, the PI buffers contain the relevant PI from storage. Then
the application gets completion and can proceed to verify that data and
PI match.

IOW, the filesystem should only ever act as a conduit. The only real
challenge as far as I can tell is how to handle concurrent protected and
unprotected updates to a page. If a non-PI-aware app updates a cached
page which is subsequently read by an app requesting PI that means we
may have to force a write-out followed by a read to get valid PI. We
could synthesize it to avoid the I/O but I think that would be violating
the premise of protected transfer. Another option is to have an
exclusive write access mechanism that only permits either protected or
unprotected access to a page.

-- 
Martin K. Petersen	Oracle Linux Engineering
