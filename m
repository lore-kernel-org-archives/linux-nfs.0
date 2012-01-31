Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:42390 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab2AaCXB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 21:23:01 -0500
To: Andreas Dilger <adilger@dilger.ca>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Chuck Lever <chuck.lever@oracle.com>,
        "lsf-pc\@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-scsi\@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [LSF/MM TOPIC] end-to-end data and metadata corruption detection
From: "Martin K. Petersen" <martin.petersen@oracle.com>
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com>
	<4F2147BA.6030607@itwm.fraunhofer.de>
	<yq1k44e1pn6.fsf@sermon.lab.mkp.net>
	<DE0353DF-83EA-480E-9C42-1EE760D6EE41@dilger.ca>
Date: Mon, 30 Jan 2012 21:22:49 -0500
In-Reply-To: <DE0353DF-83EA-480E-9C42-1EE760D6EE41@dilger.ca> (Andreas
	Dilger's message of "Thu, 26 Jan 2012 09:34:44 -0700")
Message-ID: <yq1ty3cvcee.fsf@sermon.lab.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "Andreas" == Andreas Dilger <adilger@dilger.ca> writes:

Andreas> Is there a description of sys_dio() somewhere?

This was the original draft:

	http://www.spinics.net/lists/linux-mm/msg14512.html


Andreas> In particular, I'm interested to know whether it allows full
Andreas> scatter-gather IO submission, unlike pwrite() which only allows
Andreas> multiple input buffers, and not multiple file offsets.

Each request descriptor contains buffer, target file, and offset. So
it's a single entry per descriptor. But many descriptors can be
submitted (and reaped) in a single syscall. So you don't have the single
file offset limitation of pwritev().

-- 
Martin K. Petersen	Oracle Linux Engineering
