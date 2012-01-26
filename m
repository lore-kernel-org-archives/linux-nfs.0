Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:31504 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295Ab2AZOxm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 09:53:42 -0500
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: Chuck Lever <chuck.lever@oracle.com>, lsf-pc@lists.linux-foundation.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [LSF/MM TOPIC] end-to-end data and metadata corruption detection
From: "Martin K. Petersen" <martin.petersen@oracle.com>
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com>
	<4F2147BA.6030607@itwm.fraunhofer.de>
Date: Thu, 26 Jan 2012 09:53:33 -0500
In-Reply-To: <4F2147BA.6030607@itwm.fraunhofer.de> (Bernd Schubert's message
	of "Thu, 26 Jan 2012 13:31:54 +0100")
Message-ID: <yq1k44e1pn6.fsf@sermon.lab.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "Bernd" == Bernd Schubert <bernd.schubert@itwm.fraunhofer.de> writes:

Bernd> We from the Fraunhofer FhGFS team would like to also see the T10
Bernd> DIF/DIX API exposed to user space, so that we could make use of
Bernd> it for our FhGFS file system.  And I think this feature is not
Bernd> only useful for file systems, but in general, scientific
Bernd> applications, databases, etc also would benefit from insurance of
Bernd> data integrity.

I'm attending a SNIA meeting today to discuss a (cross-OS) data
integrity aware API. We'll see what comes out of that.

With the Linux hat on I'm still mainly interested in pursuing the
sys_dio interface Joel and I proposed last year. We have good experience
with that I/O model and it suits applications that want to interact with
the protection information well. libaio is also on my list.

But obviously any help and input is appreciated...

-- 
Martin K. Petersen	Oracle Linux Engineering
