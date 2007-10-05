From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: What's slated for inclusion in 2.6.24-rc1 from the NFS
 client git tree...
Date: Fri, 5 Oct 2007 19:54:37 +0200
Message-ID: <20071005195437.2795f15a@poseidon.drzeus.cx>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
	<20071004184304.6e71ab6d@poseidon.drzeus.cx>
	<20071004114243.3161af16.akpm@linux-foundation.org>
	<1191525363.6739.12.camel@heimdal.trondhjem.org>
	<47054205.8000908@redhat.com>
	<20071005082513.4b5a058c@poseidon.drzeus.cx>
	<1191605779.6715.86.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdrNz-0006DA-9F
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 10:54:51 -0700
Received: from gateway.drzeus.cx ([85.8.24.16] helo=smtp.drzeus.cx)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IdrO3-0003IB-5L
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 10:54:56 -0700
In-Reply-To: <1191605779.6715.86.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 05 Oct 2007 13:36:19 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Fri, 2007-10-05 at 08:25 +0200, Pierre Ossman wrote:
> 
> > Print a warning or something so that they can be found. Don't go
> > breaking systems left and right. People have better things to do
> > than to fix the build systems for ever program they use.
> 
> The kernel knows bugger all about what glibc function your program is
> calling. The problem here is precisely that newer versions of glibc
> will transform legacy 32-bit stat() calls into 64-bit stat64() calls,
> then will complain when the result overflows.
> 

Right, I didn't suggest that this had to be done in the kernel. My
point was that first you mark something as deprecated, make a lot of
noise when someone uses it so that problems can be identified, and some
time later you remove it. You don't just remove it and let production
systems deal with the fallout.

Rgds
-- 
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  PulseAudio, core developer          http://pulseaudio.org
  rdesktop, core developer          http://www.rdesktop.org

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
