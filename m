From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] add MODULE_DESCRIPTION to nfs module, update NFS references in MAINTAINERS
Date: Tue, 25 Jan 2005 23:08:29 +0000
Message-ID: <20050125230829.GA30641@infradead.org>
References: <1106692805.4420.34.camel@w-bwa3.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtZnZ-0004SJ-Fe
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 15:08:37 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CtZnY-0001Bh-0g
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 15:08:37 -0800
To: Bruce Allan <bwa@us.ibm.com>
In-Reply-To: <1106692805.4420.34.camel@w-bwa3.beaverton.ibm.com>
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

> +MODULE_DESCRIPTION("NFS client module (http://nfs.sourceforge.net)");

I've not seen a single other module with an url in MODULE_DESCRIPTION()
yet, and it doesn't look like the right thing either.



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
