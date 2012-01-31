Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:64555 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346Ab2AaUEb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2012 15:04:31 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        lsf-pc@lists.linux-foundation.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [LSF/MM TOPIC] end-to-end data and metadata corruption detection
From: "Martin K. Petersen" <martin.petersen@oracle.com>
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com>
	<4F2147BA.6030607@itwm.fraunhofer.de>
	<yq1k44e1pn6.fsf@sermon.lab.mkp.net>
	<4F217F0C.6030105@itwm.fraunhofer.de>
	<1327620104.6151.23.camel@dabdike.int.hansenpartnership.com>
	<4F283E0E.7010407@itwm.fraunhofer.de>
	<22F078FB-0EB9-4A68-82C1-CB4059356EFF@oracle.com>
Date: Tue, 31 Jan 2012 15:04:20 -0500
In-Reply-To: <22F078FB-0EB9-4A68-82C1-CB4059356EFF@oracle.com> (Chuck Lever's
	message of "Tue, 31 Jan 2012 14:21:48 -0500")
Message-ID: <yq1y5snskor.fsf@sermon.lab.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "Chuck" == Chuck Lever <chuck.lever@oracle.com> writes:

>> I guess if we couldn't use the page cache, we probably wouldn't
>> attempt to use DIF/DIX interface, but will calculate our own
>> checksums once we are going to work on the data integrity feature on
>> our side.

Chuck> This is interesting.  I imagine the Linux kernel NFS server will
Chuck> have the same issue: it depends on the page cache for good
Chuck> performance, and does not, itself, use direct I/O.

Just so we're perfectly clear here: There's nothing that prevents you
from hanging protection information off of your page private pointer so
it can be submitted along with the data.

The concern is purely that the filesystem owning the pages need to
handle access conflicts (racing DI and non-DI updates) and potentially
sub page modifications for small filesystem block sizes.

The other problem with buffered I/O is that the notion of "all these
pages are belong to us^wone write request" goes out the window. You
really need something like aio to be able to be able to get completion
status and re-drive the I/O if there's an integrity error. Otherwise you
might as well just let the kernel autoprotect the pages from the block
layer down (which is what we do now).

-- 
Martin K. Petersen	Oracle Linux Engineering
