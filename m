From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] add MODULE_DESCRIPTION to nfs module, update NFS
 references in MAINTAINERS
Date: Wed, 26 Jan 2005 21:36:35 +1100
Message-ID: <16887.29363.367331.643681@cse.unsw.edu.au>
References: <1106692805.4420.34.camel@w-bwa3.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtkgI-0006a3-PE
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 02:45:50 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CtkgI-0000xt-1y
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 02:45:50 -0800
To: bwa@us.ibm.com
In-Reply-To: message from Bruce Allan on Tuesday January 25
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

On Tuesday January 25, bwa@us.ibm.com wrote:
> To direct people to the appropriate resources when experiencing problems
> with the NFS client here is a simple patch to 1) add module description
> (with link to NFS documentation) to the nfs module, and 2) update the
> NFS mailing list and web resources to the MAINTAINERS file.
> 
> Patch created against 2.6.11-rc2.
> 
> Signed-off-by: Bruce Allan <bwa@us.ibm.com>
> 
...
> diff -urp linux-2.6.11-rc2-vanilla/MAINTAINERS linux-2.6.11-rc2/MAINTAINERS
> --- linux-2.6.11-rc2-vanilla/MAINTAINERS	2005-01-24 09:17:40.000000000 -0800
> +++ linux-2.6.11-rc2/MAINTAINERS	2005-01-25 11:29:51.000000000 -0800
> @@ -1612,7 +1612,9 @@ S:	Maintained
>  NFS CLIENT
>  P:	Trond Myklebust
>  M:	trond.myklebust@fys.uio.no
> -L:	linux-kernel@vger.kernel.org
> +L:	nfs@lists.sourceforge.net

Trouble with this is that the last I heard, nfs@lists.sourceforge.net
was subscriber-only, and there are those who don't like non-open lists 
in MAINTAINERS.  I realise that the same list is given for "KERNEL
NFSD", but that was put there when it was still open.....

NeilBrown

> +W:	http://nfs.sourceforge.net
> +W:	http://linux-nfs.org
>  S:	Maintained
>  
>  NI5010 NETWORK DRIVER
> 
> 
> Regards,
> ---
> Bruce Allan
> Software Engineer, Linux Technology Center
> IBM Corporation, Beaverton OR USA


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
