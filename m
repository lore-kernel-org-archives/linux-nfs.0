From: Bruce Allan <bwa@us.ibm.com>
Subject: Re: [PATCH] add MODULE_DESCRIPTION to nfs module, update NFS
	references in MAINTAINERS
Date: Wed, 26 Jan 2005 08:56:20 -0800
Message-ID: <1106758580.4413.20.camel@w-bwa3.beaverton.ibm.com>
References: <1106692805.4420.34.camel@w-bwa3.beaverton.ibm.com>
	 <20050125230829.GA30641@infradead.org>
	 <1106698790.4420.64.camel@w-bwa3.beaverton.ibm.com>
	 <20050126080547.GA6067@infradead.org>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtqSz-0007Vk-Et
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 08:56:29 -0800
Received: from e34.co.us.ibm.com ([32.97.110.132])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CtqSy-0001EO-1C
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 08:56:29 -0800
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j0QGuMaQ116184
	for <nfs@lists.sourceforge.net>; Wed, 26 Jan 2005 11:56:22 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0QGuM6B317118
	for <nfs@lists.sourceforge.net>; Wed, 26 Jan 2005 09:56:22 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j0QGuLDN008626
	for <nfs@lists.sourceforge.net>; Wed, 26 Jan 2005 09:56:21 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050126080547.GA6067@infradead.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, 2005-01-26 at 00:05, Christoph Hellwig wrote:
> On Tue, Jan 25, 2005 at 04:19:50PM -0800, Bruce Allan wrote:
> > Besides the NFS configuration comments in ./fs/Kconfig and the
> > MAINTAINERS file (which might not be present on a system), can you
> > suggest an alternative location to provide this pointer?
> 
> MAINTAINERS is exactly the right place.
> 
> 
Yes, MAINTAINERS is the best place for that info, but there are many
Linux production systems out there that do not have the kernel source
installed.  Where on these machines is one supposed to get that kind of
information?

Regards,
---
Bruce Allan
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR USA



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
