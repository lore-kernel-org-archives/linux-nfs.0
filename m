From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] hide kernel includes in include/linux/nfs.h
Date: Mon, 21 Feb 2005 10:17:43 -0500
Message-ID: <1108999063.10135.44.camel@lade.trondhjem.org>
References: <20050220213647.GB21877@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NeilBrown <neilb@cse.unsw.edu.au>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3FJz-0004xL-K4
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 07:18:03 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D3FJw-0001Vc-VT
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 07:18:03 -0800
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20050220213647.GB21877@suse.de>
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

There is really no good reason why nfs.h should be including those two
files in the first place. Let's just throw them out altogether.

The other such cleanup we want to do is to move the definition of
"struct nfs_fh" into one of the NFS client-specific header files.

Cheers,
  Trond

su den 20.02.2005 Klokka 22:36 (+0100) skreiv Olaf Hering:
> msg_prot.h and string.h have both kernel only content. I want to get to
> the point were klibc can be shipped standalone with only a few required
> headers. This patch shrinks the header file list to include.
> It changes also a #ifdef, so unifdef can do its job.
> 
> 
> Signed-off-by: Olaf Hering <olh@suse.de>
> 
> diff -purN linux-2.6.11-rc4.orig/include/linux/nfs.h linux-2.6.11-rc4-klibc/include/linux/nfs.h
> --- linux-2.6.11-rc4.orig/include/linux/nfs.h	2005-02-13 04:07:01.000000000 +0100
> +++ linux-2.6.11-rc4-klibc/include/linux/nfs.h	2005-02-20 17:03:31.814003771 +0100
> @@ -7,9 +7,6 @@
>  #ifndef _LINUX_NFS_H
>  #define _LINUX_NFS_H
>  
> -#include <linux/sunrpc/msg_prot.h>
> -#include <linux/string.h>
> -
>  #define NFS_PROGRAM	100003
>  #define NFS_PORT	2049
>  #define NFS_MAXDATA	8192
> @@ -129,7 +126,11 @@ enum nfs_ftype {
>  	NFFIFO = 8
>  };
>  
> -#if defined(__KERNEL__)
> +#ifdef __KERNEL__
> +
> +#include <linux/sunrpc/msg_prot.h>
> +#include <linux/string.h>
> +
>  /*
>   * This is the kernel NFS client file handle representation
>   */
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
