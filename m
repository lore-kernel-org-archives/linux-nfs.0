From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: What's slated for inclusion in 2.6.24-rc1 from the NFS
 client git tree...
Date: Fri, 5 Oct 2007 08:25:13 +0200
Message-ID: <20071005082513.4b5a058c@poseidon.drzeus.cx>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
	<20071004184304.6e71ab6d@poseidon.drzeus.cx>
	<20071004114243.3161af16.akpm@linux-foundation.org>
	<1191525363.6739.12.camel@heimdal.trondhjem.org>
	<47054205.8000908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Idgce-0007c7-U6
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 23:25:16 -0700
Received: from gateway.drzeus.cx ([85.8.24.16] helo=smtp.drzeus.cx)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Idgcg-0004un-OG
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 23:25:22 -0700
In-Reply-To: <47054205.8000908@redhat.com>
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

On Thu, 04 Oct 2007 15:41:57 -0400
Peter Staubach <staubach@redhat.com> wrote:

> 
> I would agree.  The 64 bit fileids will only become visible when
> the server is exporting file systems which contain fileids which
> are bigger than 32 bits and then only when the application
> encounters these files.
> 

Or, as has been pointed out, when the server is not the Linux in-kernel
NFS server.

> Also, these 32-bit legacy applications are going to have a
> problem if they are ever run on a system which contains local
> file systems which expose the large fileids.
> 

Agreed. And I'd probably like a way around that as well. But local
files have never worked, NFS has. So removing it from NFS (where it is
more likely to occur IMO) would be a regression.

> It would be better to identify these applications and get them
> fixed.  The world is evolving and it is time for them to do so.
> 

Print a warning or something so that they can be found. Don't go
breaking systems left and right. People have better things to do than
to fix the build systems for ever program they use.

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
