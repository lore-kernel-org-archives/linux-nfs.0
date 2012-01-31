Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:53136 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365Ab2AaTWg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2012 14:22:36 -0500
Message-ID: <4F283F7A.4020905@itwm.fraunhofer.de>
Date: Tue, 31 Jan 2012 20:22:34 +0100
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: "Martin K. Petersen" <martin.petersen@oracle.com>
CC: Chuck Lever <chuck.lever@oracle.com>, lsf-pc@lists.linux-foundation.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [LSF/MM TOPIC] end-to-end data and metadata corruption detection
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com> <4F2147BA.6030607@itwm.fraunhofer.de> <yq1k44e1pn6.fsf@sermon.lab.mkp.net> <4F217F0C.6030105@itwm.fraunhofer.de> <yq1y5sovcyw.fsf@sermon.lab.mkp.net>
In-Reply-To: <yq1y5sovcyw.fsf@sermon.lab.mkp.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/31/2012 03:10 AM, Martin K. Petersen wrote:
>>>>>> "Bernd" == Bernd Schubert<bernd.schubert@itwm.fraunhofer.de>  writes:
>
> Bernd>  Hmm, direct IO would mean we could not use the page cache. As we
> Bernd>  are using it, that would not really suit us. libaio then might be
> Bernd>  another option then.
>
> Bernd>  What kind of help do you exactly need?
>
> As far as libaio is concerned I had a PoC working a few years ago. I'll
> be happy to revive it if people are actually interested. So a real world
> use case would be a great help...

I guess it would be useful for us, although right now data integrity is 
not on our todo list for the next couple of months. Unless other people 
would be interested in it right now, can we postpone for some time?

>
> But James is right that buffered I/O is much more challenging than
> direct I/O. And all the use cases we have had have involved databases
> and business apps that were doing direct I/O anyway.
>

I guess we should talk to developers of other parallel file systems and 
see what they think about it. I think cephfs already uses data integrity 
provided by btrfs, although I'm not entirely sure and need to check the 
code. As I said before, Lustre does network checksums already and 
*might* be interested.


Cheers,
Bernd
