Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:58104 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753179Ab2BAQw6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 11:52:58 -0500
Message-ID: <1328115175.2768.11.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] end-to-end data and metadata corruption
 detection
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Chris Mason <chris.mason@oracle.com>
Cc: Gregory Farnum <gregory.farnum@dreamhost.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        lsf-pc@lists.linux-foundation.org
Date: Wed, 01 Feb 2012 10:52:55 -0600
In-Reply-To: <20120201164521.GY16796@shiny>
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com>
	 <4F2147BA.6030607@itwm.fraunhofer.de> <yq1k44e1pn6.fsf@sermon.lab.mkp.net>
	 <4F217F0C.6030105@itwm.fraunhofer.de> <yq1y5sovcyw.fsf@sermon.lab.mkp.net>
	 <4F283F7A.4020905@itwm.fraunhofer.de>
	 <CAF3hT9AgVpcZkGLkr4EH4x4heNFgxNykM4Mp3V_C-RBSwJh7mA@mail.gmail.com>
	 <20120201164521.GY16796@shiny>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-02-01 at 11:45 -0500, Chris Mason wrote:
> On Tue, Jan 31, 2012 at 11:28:26AM -0800, Gregory Farnum wrote:
> > On Tue, Jan 31, 2012 at 11:22 AM, Bernd Schubert
> > <bernd.schubert@itwm.fraunhofer.de> wrote:
> > > I guess we should talk to developers of other parallel file systems and see
> > > what they think about it. I think cephfs already uses data integrity
> > > provided by btrfs, although I'm not entirely sure and need to check the
> > > code. As I said before, Lustre does network checksums already and *might* be
> > > interested.
> > 
> > Actually, right now Ceph doesn't check btrfs' data integrity
> > information, but since Ceph doesn't have any data-at-rest integrity
> > verification it relies on btrfs if you want that. Integrating
> > integrity verification throughout the system is on our long-term to-do
> > list.
> > We too will be said if using a kernel-level integrity system requires
> > using DIO, although we could probably work out a way to do
> > "translation" between our own integrity checksums and the
> > btrfs-generated ones if we have to (thanks to replication).
> 
> DIO isn't really required, but doing this without synchronous writes
> will get painful in a hurry.  There's nothing wrong with letting the
> data sit in the page cache after the IO is done though.

I broadly agree with this, but even if you do sync writes and cache read
only copies, we still have the problem of how we do the read side
verification of DIX.  In theory, when you read, you could either get the
cached copy or an actual read (which will supply protection
information), so for the cached copy we need to return cached protection
information implying that we need some way of actually caching it.

James


