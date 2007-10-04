From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: What's slated for inclusion in 2.6.24-rc1 from the NFS
 client git tree...
Date: Thu, 4 Oct 2007 08:52:06 +0200
Message-ID: <20071004085206.0a8e37b5@poseidon.drzeus.cx>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdKZB-0006eb-8g
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 23:52:13 -0700
Received: from gateway.drzeus.cx ([85.8.24.16] helo=smtp.drzeus.cx)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IdKZE-0006Sj-37
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 23:52:18 -0700
In-Reply-To: <1191454876.6726.32.camel@heimdal.trondhjem.org>
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

On Wed, 03 Oct 2007 19:41:16 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> We also have the 64-bit inode support from RedHat/Peter Staubach.
> 

As has been pointed[1] out[2], this will cause regressions for non-LFS
applications (of which there are still lots and lots). This change
should be in feature-removal (the "feature" being removed is legacy
support for non-LFS applications using NFS servers that make full use
of the protocol) and preferably accompanied with appropriate user space
changes (e.g. compatibility option in glibc).

[1] https://bugzilla.redhat.com/show_bug.cgi?id=241348
[2] http://marc.info/?l=linux-nfs&m=118701088726477&w=2

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
