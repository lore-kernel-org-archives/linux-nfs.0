From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Possible bugs in nfs-utils
Date: Thu, 22 Jun 2006 18:05:20 +1000
Message-ID: <1150963520.20487.511.camel@hole.melbourne.sgi.com>
References: <20060619203025.GA7102@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FtKC3-0005Ny-4o
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 01:05:39 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FtKC2-0002uQ-UX
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 01:05:39 -0700
To: Michael Halcrow <mhalcrow@us.ibm.com>
In-Reply-To: <20060619203025.GA7102@us.ibm.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2006-06-20 at 06:30, Michael Halcrow wrote:
> I ran nfs-utils through the Coverity source code scanner, and the
> following items were flagged that I thought might merit a second
> glance (source from util-linux-2.13-pre7.tar.bz2). Those with a more
> intimate knowledge of the code base can probably help out in
> determining whether some of these really are problematic:

Some of these look worth fixing.  Neil, I have a bunch of
trivial nfs-utils compile warnings fixes waiting to be
pushed, shall I add these in too?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
