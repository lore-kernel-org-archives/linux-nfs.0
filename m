Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:43510 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751788Ab2AZXVq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 18:21:46 -0500
Message-ID: <1327620104.6151.23.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [LSF/MM TOPIC] end-to-end data and metadata corruption detection
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        lsf-pc@lists.linux-foundation.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>
Date: Thu, 26 Jan 2012 17:21:44 -0600
In-Reply-To: <4F217F0C.6030105@itwm.fraunhofer.de>
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com>
	 <4F2147BA.6030607@itwm.fraunhofer.de> <yq1k44e1pn6.fsf@sermon.lab.mkp.net>
	 <4F217F0C.6030105@itwm.fraunhofer.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-01-26 at 17:27 +0100, Bernd Schubert wrote:
> On 01/26/2012 03:53 PM, Martin K. Petersen wrote:
> >>>>>> "Bernd" == Bernd Schubert<bernd.schubert@itwm.fraunhofer.de>  writes:
> >
> > Bernd>  We from the Fraunhofer FhGFS team would like to also see the T10
> > Bernd>  DIF/DIX API exposed to user space, so that we could make use of
> > Bernd>  it for our FhGFS file system.  And I think this feature is not
> > Bernd>  only useful for file systems, but in general, scientific
> > Bernd>  applications, databases, etc also would benefit from insurance of
> > Bernd>  data integrity.
> >
> > I'm attending a SNIA meeting today to discuss a (cross-OS) data
> > integrity aware API. We'll see what comes out of that.
> >
> > With the Linux hat on I'm still mainly interested in pursuing the
> > sys_dio interface Joel and I proposed last year. We have good experience
> > with that I/O model and it suits applications that want to interact with
> > the protection information well. libaio is also on my list.
> >
> > But obviously any help and input is appreciated...
> >
> 
> I guess you are referring to the interface described here
> 
> http://www.spinics.net/lists/linux-mm/msg14512.html
> 
> Hmm, direct IO would mean we could not use the page cache. As we are 
> using it, that would not really suit us. libaio then might be another 
> option then.

Are you really sure you want protection information and the page cache?
The reason for using DIO is that no-one could really think of a valid
page cache based use case.  What most applications using protection
information want is to say: This is my data and this is the integrity
verification, send it down and assure me you wrote it correctly.  If you
go via the page cache, we have all sorts of problems, like our
granularity is a page (not a block) so you'd have to guarantee to write
a page at a time (a mechanism for combining subpage units of protection
information sounds like a nightmare).  The write becomes mark page dirty
and wait for the system to flush it, and we can update the page in the
meantime.  How do we update the page and its protection information
atomically.  What happens if the page gets updated but no protection
information is supplied and so on ...  The can of worms just gets more
squirmy.  Doing DIO only avoids all of this.

James


