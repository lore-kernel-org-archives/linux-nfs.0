From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: File system cache corruptions?
Date: Wed, 06 Oct 2004 19:45:30 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097084729.5245.44.camel@lade.trondhjem.org>
References: <4164201A.8020005@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFFrJ-0001ZD-7y
	for nfs@lists.sourceforge.net; Wed, 06 Oct 2004 10:45:49 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CFFrI-0008Gp-EK
	for nfs@lists.sourceforge.net; Wed, 06 Oct 2004 10:45:49 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <4164201A.8020005@moving-picture.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

P=E5 on , 06/10/2004 klokka 18:40, skreiv James Pearson:

> Any ideas on what may be causing this?

Shared mmapped files tend not to be easy to keep consistent w.r.t. the
server, because mmap pins the pages in memory.

Instead of copying data into the mmapped file, it is better to create a
new file, then rename it onto the old one (like tools such as GNU
install do for you).

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
