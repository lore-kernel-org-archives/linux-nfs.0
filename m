From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH 2.4] (retry) increase NFSSVC_MAXBLKSIZE on large page machines
Date: Tue, 27 Jul 2004 14:10:25 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16645.54705.169914.601299@cse.unsw.edu.au>
References: <20040726081439.GE17056@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpJIO-00030F-G6
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 21:10:32 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BpJIN-0001Hk-PH
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 21:10:32 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: message from Greg Banks on Monday July 26
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

On Monday July 26, gnb@sgi.com wrote:
> G'day,
> 
> I've been out of the loop for a few weeks now so I'm getting back
> in by sending and resending a bunch of patches.
> 
> This one (for 2.4 only) was sent twice but has not yet appeared in
> Marcello's BK.

Sorry 'bout that.  I keep remembering it when I'm not in a position to
do anything about it...
I've just sent it and the TCP-not-experimental patch to Marcelo.

thanks,

NeilBrown

> 
> http://marc.theaimsgroup.com/?l=linux-nfs&m=107002386729570&w=2
> http://marc.theaimsgroup.com/?l=linux-kernel&m=108391490102531&w=2
> 
> This patch makes NFSSVC_MAXBLKSIZE depend on PAGE_SIZE so that machines
> with large page sizes can take advantage of that feature to serve NFS
> with larger blocksizes, increasing performance and avoiding a fallback
> to synchronous traffic between machines with page sizes greater than 8K.
> Also, documents the actual constraints on NFSSVC_MAXBLKSIZE.
> 
> 
> --- /usr/tmp/TmpDir.16250-0/linux/linux/include/linux/nfsd/const.h_1.5	Fri May  7 17:20:22 2004
> +++ /usr/tmp/TmpDir.16250-0/linux/linux/include/linux/nfsd/const.h	Fri May  7 17:20:22 2004
> @@ -12,6 +12,7 @@
>  #include <linux/nfs.h>
>  #include <linux/nfs2.h>
>  #include <linux/nfs3.h>
> +#include <asm/page.h>
>  
>  /*
>   * Maximum protocol version supported by knfsd
> @@ -19,9 +20,16 @@
>  #define NFSSVC_MAXVERS		3
>  
>  /*
> - * Maximum blocksize supported by daemon currently at 8K
> + * Maximum blocksize supported by daemon.  We want the largest
> + * value which 1) fits in a UDP datagram less some headers
> + * 2) is a multiple of page size 3) can be successfully kmalloc()ed
> + * by each nfsd.   
>   */
> -#define NFSSVC_MAXBLKSIZE	(8*1024)
> +#if PAGE_SIZE > (16*1024)
> +#define NFSSVC_MAXBLKSIZE	(32*1024)
> +#else
> +#define NFSSVC_MAXBLKSIZE	(2*PAGE_SIZE)
> +#endif
>  
>  #ifdef __KERNEL__
> 
> Greg.
> -- 
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
