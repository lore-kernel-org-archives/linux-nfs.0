Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:53336 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373Ab2AaCKn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 21:10:43 -0500
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Chuck Lever <chuck.lever@oracle.com>,
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
Date: Mon, 30 Jan 2012 21:10:31 -0500
In-Reply-To: <4F217F0C.6030105@itwm.fraunhofer.de> (Bernd Schubert's message
	of "Thu, 26 Jan 2012 17:27:56 +0100")
Message-ID: <yq1y5sovcyw.fsf@sermon.lab.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "Bernd" == Bernd Schubert <bernd.schubert@itwm.fraunhofer.de> writes:

Bernd> Hmm, direct IO would mean we could not use the page cache. As we
Bernd> are using it, that would not really suit us. libaio then might be
Bernd> another option then.

Bernd> What kind of help do you exactly need?

As far as libaio is concerned I had a PoC working a few years ago. I'll
be happy to revive it if people are actually interested. So a real world
use case would be a great help...

But James is right that buffered I/O is much more challenging than
direct I/O. And all the use cases we have had have involved databases
and business apps that were doing direct I/O anyway.

-- 
Martin K. Petersen	Oracle Linux Engineering
