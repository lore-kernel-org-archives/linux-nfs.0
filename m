Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:53441 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674Ab2AZQ2B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 11:28:01 -0500
Message-ID: <4F217F0C.6030105@itwm.fraunhofer.de>
Date: Thu, 26 Jan 2012 17:27:56 +0100
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: "Martin K. Petersen" <martin.petersen@oracle.com>
CC: Chuck Lever <chuck.lever@oracle.com>, lsf-pc@lists.linux-foundation.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [LSF/MM TOPIC] end-to-end data and metadata corruption detection
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com> <4F2147BA.6030607@itwm.fraunhofer.de> <yq1k44e1pn6.fsf@sermon.lab.mkp.net>
In-Reply-To: <yq1k44e1pn6.fsf@sermon.lab.mkp.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/26/2012 03:53 PM, Martin K. Petersen wrote:
>>>>>> "Bernd" == Bernd Schubert<bernd.schubert@itwm.fraunhofer.de>  writes:
>
> Bernd>  We from the Fraunhofer FhGFS team would like to also see the T10
> Bernd>  DIF/DIX API exposed to user space, so that we could make use of
> Bernd>  it for our FhGFS file system.  And I think this feature is not
> Bernd>  only useful for file systems, but in general, scientific
> Bernd>  applications, databases, etc also would benefit from insurance of
> Bernd>  data integrity.
>
> I'm attending a SNIA meeting today to discuss a (cross-OS) data
> integrity aware API. We'll see what comes out of that.
>
> With the Linux hat on I'm still mainly interested in pursuing the
> sys_dio interface Joel and I proposed last year. We have good experience
> with that I/O model and it suits applications that want to interact with
> the protection information well. libaio is also on my list.
>
> But obviously any help and input is appreciated...
>

I guess you are referring to the interface described here

http://www.spinics.net/lists/linux-mm/msg14512.html

Hmm, direct IO would mean we could not use the page cache. As we are 
using it, that would not really suit us. libaio then might be another 
option then.

What kind of help do you exactly need?


Thanks,
Bernd
