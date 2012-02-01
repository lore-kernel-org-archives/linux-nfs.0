Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:58423 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754789Ab2BASQI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 13:16:08 -0500
Message-ID: <1328120165.2768.39.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] end-to-end data and metadata corruption
 detection
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Bernd Schubert <bernd.schubert@fastmail.fm>
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
Date: Wed, 01 Feb 2012 12:16:05 -0600
In-Reply-To: <4F297D90.1010509@fastmail.fm>
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com>
	 <4F2147BA.6030607@itwm.fraunhofer.de> <yq1k44e1pn6.fsf@sermon.lab.mkp.net>
	 <4F217F0C.6030105@itwm.fraunhofer.de> <yq1y5sovcyw.fsf@sermon.lab.mkp.net>
	 <4F283F7A.4020905@itwm.fraunhofer.de>
	 <CAF3hT9AgVpcZkGLkr4EH4x4heNFgxNykM4Mp3V_C-RBSwJh7mA@mail.gmail.com>
	 <20120201164521.GY16796@shiny>
	 <1328115175.2768.11.camel@dabdike.int.hansenpartnership.com>
	 <20120201174131.GD16796@shiny> <4F297D90.1010509@fastmail.fm>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-02-01 at 18:59 +0100, Bernd Schubert wrote:
> On 02/01/2012 06:41 PM, Chris Mason wrote:
> > On Wed, Feb 01, 2012 at 10:52:55AM -0600, James Bottomley wrote:
> >> On Wed, 2012-02-01 at 11:45 -0500, Chris Mason wrote:
[...]
> >>> DIO isn't really required, but doing this without synchronous writes
> >>> will get painful in a hurry.  There's nothing wrong with letting the
> >>> data sit in the page cache after the IO is done though.
> >>
> >> I broadly agree with this, but even if you do sync writes and cache read
> >> only copies, we still have the problem of how we do the read side
> >> verification of DIX.  In theory, when you read, you could either get the
> >> cached copy or an actual read (which will supply protection
> >> information), so for the cached copy we need to return cached protection
> >> information implying that we need some way of actually caching it.
> >
> > Good point, reading from the cached copy is a lower level of protection
> > because in theory bugs in your scsi drivers could corrupt the pages
> > later on.
> 
> But that only matters if the application is going to verify if data are 
> really on disk. For example (client server scenario)

Um, well, then why do you want DIX?  If you don't care about having the
client verify the data, that means you trust the integrity of the page
cache and then you just use the automated DIF within the driver layer
and SCSI will verify the data all the way up until block places it in
the page cache.

The whole point of supplying protection information to user space is
that the application can verify the data didn't get corrupted after it
left the DIF protected block stack.

> 1) client-A writes a page
> 2) client-B reads this page
> 
> client-B is simply not interested here where it gets the page from, as 
> long as it gets correct data.

How does it know it got correct data if it doesn't verify?  Something
might have corrupted the page between the time the block layer placed
the DIF verified data there and the client reads it.

>  The network files system in between also 
> will just be happy existing in-cache crcs for network verification.
> Only if the page is later on dropped from the cache and read again, 
> on-disk crcs matter. If those are bad, one of the layers is going to 
> complain or correct those data.
> 
> If the application wants to check data on disk it can either use DIO or 
> alternatively something like fadvsise(DONTNEED_LOCAL_AND_REMOTE) 
> (something I wanted to propose for some time already, at least I'm not 
> happy that posix_fadvise(POSIX_FADV_DONTNEED) is not passed to the file 
> system at all).

supplying protection information to user space isn't about the
application checking what's on disk .. there's automatic verification in
the chain to do that (both the HBA and the disk will check the
protection information on entry/exit and transfer).  Supplying
protection information to userspace is about checking nothing went wrong
in the handoff between the end of the DIF stack and the application.

James


