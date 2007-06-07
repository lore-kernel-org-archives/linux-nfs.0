From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: page allocation in nfs_symlink
Date: Thu, 07 Jun 2007 09:28:23 -0400
Message-ID: <1181222903.6442.0.camel@heimdal.trondhjem.org>
References: <20070607091842.09c23fd8.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HwI2S-0001Rh-AW
	for nfs@lists.sourceforge.net; Thu, 07 Jun 2007 06:28:33 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19yhSL/A5Gjv17H12JwOD3im8lQ7Oin8oI=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HwI2V-0007j9-1Z
	for nfs@lists.sourceforge.net; Thu, 07 Jun 2007 06:28:35 -0700
In-Reply-To: <20070607091842.09c23fd8.jlayton@redhat.com>
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

On Thu, 2007-06-07 at 09:18 -0400, Jeff Layton wrote:
> I was reviewing a patch the other day and noticed this in recent
> versions of nfs_symlink():
> 
>         page = alloc_page(GFP_KERNEL);
>         if (!page) {
>                 unlock_kernel();
>                 return -ENOMEM;
>         }
> 
>         kaddr = kmap_atomic(page, KM_USER0);
>         memcpy(kaddr, symname, pathlen);
>         if (pathlen < PAGE_SIZE)
>                 memset(kaddr + pathlen, 0, PAGE_SIZE - pathlen);
>         kunmap_atomic(kaddr, KM_USER0);
> 
> I'm a bit confused and so am hoping someone can clarify. If we're
> allocating a GFP_KERNEL page, then it should be directly addressable by
> the kernel (via page_address()). So we really shouldn't need to use a
> kmap/unmap here, right?
> 
> Also, it looks like most pagecache pages are allocated using
> GFP_HIGHUSER. Is there something special about symlinks that means that
> we need to use normal zone pages here? While I haven't tested it, it
> seems like we ought to be able to do alloc_page(GFP_HIGHUSER) here
> instead.
> 
> Am I missing something?

No. I think you're right: it should be safe to use GFP_HIGHUSER.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
