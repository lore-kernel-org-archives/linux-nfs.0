From: Bruce Allan <bwa@us.ibm.com>
Subject: Re: [PATCH] add MODULE_DESCRIPTION to nfs module, update NFS
	references in MAINTAINERS
Date: Tue, 25 Jan 2005 16:19:50 -0800
Message-ID: <1106698790.4420.64.camel@w-bwa3.beaverton.ibm.com>
References: <1106692805.4420.34.camel@w-bwa3.beaverton.ibm.com>
	 <20050125230829.GA30641@infradead.org>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ctauc-0007me-RQ
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 16:19:58 -0800
Received: from e34.co.us.ibm.com ([32.97.110.132])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1Ctauc-0000CN-Eg
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 16:19:58 -0800
Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j0Q0JqaQ008106
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 19:19:52 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0Q0Jq1c359808
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 17:19:52 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j0Q0JpZY015146
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 17:19:51 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050125230829.GA30641@infradead.org>
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

On Tue, 2005-01-25 at 15:08, Christoph Hellwig wrote:
> > +MODULE_DESCRIPTION("NFS client module (http://nfs.sourceforge.net)");
> 
> I've not seen a single other module with an url in MODULE_DESCRIPTION()
> yet, and it doesn't look like the right thing either.
> 
> 
I'm curious, why not?  The MODULE_DESCRIPTION is meant to provide a
description of what the module does; the url referenced is to the
SourceForge project site for NFS which has the NFS Overview, FAQ, HOWTO,
and other assorted links which more thoroughly document just that.

Besides the NFS configuration comments in ./fs/Kconfig and the
MAINTAINERS file (which might not be present on a system), can you
suggest an alternative location to provide this pointer?

The idea is to provide a means for the user with a problem to be able to
quickly and easily find the proper assistance without wasting
inappropriate bandwidth, or better yet, resolve the problem on their
own.  And, yes, I realize this won't work if nfs/nfsd is statically
built into the kernel.

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
