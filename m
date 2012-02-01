Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:53425 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab2BAXD3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 18:03:29 -0500
Message-ID: <4F29C4A4.8020005@panasas.com>
Date: Thu, 2 Feb 2012 01:03:00 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Martin K. Petersen" <martin.petersen@oracle.com>
CC: James Bottomley <James.Bottomley@HansenPartnership.com>,
        Chris Mason <chris.mason@oracle.com>,
        Gregory Farnum <gregory.farnum@dreamhost.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        <linux-scsi@vger.kernel.org>,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        <lsf-pc@lists.linux-foundation.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] end-to-end data and metadata corruption
 detection
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com> <4F2147BA.6030607@itwm.fraunhofer.de> <yq1k44e1pn6.fsf@sermon.lab.mkp.net> <4F217F0C.6030105@itwm.fraunhofer.de> <yq1y5sovcyw.fsf@sermon.lab.mkp.net> <4F283F7A.4020905@itwm.fraunhofer.de> <CAF3hT9AgVpcZkGLkr4EH4x4heNFgxNykM4Mp3V_C-RBSwJh7mA@mail.gmail.com> <20120201164521.GY16796@shiny> <1328115175.2768.11.camel@dabdike.int.hansenpartnership.com> <yq1d39ys9n1.fsf@sermon.lab.mkp.net>
In-Reply-To: <yq1d39ys9n1.fsf@sermon.lab.mkp.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/01/2012 08:15 PM, Martin K. Petersen wrote:
>>>>>> "James" == James Bottomley <James.Bottomley@HansenPartnership.com> writes:
> 
> IOW, the filesystem should only ever act as a conduit. The only real
> challenge as far as I can tell is how to handle concurrent protected and
> unprotected updates to a page. If a non-PI-aware app updates a cached
> page which is subsequently read by an app requesting PI that means we
> may have to force a write-out followed by a read to get valid PI. We
> could synthesize it to avoid the I/O but I think that would be violating
> the premise of protected transfer. Another option is to have an
> exclusive write access mechanism that only permits either protected or
> unprotected access to a page.

Yes. a protected write implies a byte-range locking on the file.
(And can be implemented with one)

Also the open() call demands an O_PROTECT option. Protection is
then a file attribute as well.

> 

Boaz
