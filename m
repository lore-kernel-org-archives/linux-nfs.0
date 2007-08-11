From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Sat, 11 Aug 2007 11:12:41 -0400
Message-ID: <1186845161.17941.27.camel@heimdal.trondhjem.org>
References: <46B37CDE.1070904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJsdx-0008E9-Oo
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 08:12:46 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/F4M8u+WHcDuWpBzivbiunZdkj0QYlaeI=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJse0-0003oT-VK
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 08:12:50 -0700
In-Reply-To: <46B37CDE.1070904@redhat.com>
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

On Fri, 2007-08-03 at 15:07 -0400, Peter Staubach wrote:
> Hi.
> 
> Attached is a patch to modify the NFS client code to support
> 64 bit ino's, as appropriate for the system and the NFS
> protocol version.
> 
> The code basically just expand the NFS interfaces for routines
> which handle ino's from using ino_t to u64 and then uses the
> fileid in the nfs_inode instead of i_ino in the inode.  The
> code paths that were updated are in the getattr method and
> the readdir methods.
> 
> This should be no real change on 64 bit platforms.  Since
> the ino_t is an unsigned long, it would already be 64 bits
> wide.
> 
>     Thanx...
> 
>        ps

Applied and queued for 2.6.24

Thanks Peter!

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
