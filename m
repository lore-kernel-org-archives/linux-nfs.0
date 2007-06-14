From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]is_power_of_2-nfs/internal.h
Date: Thu, 14 Jun 2007 11:45:58 -0400
Message-ID: <1181835958.6957.2.camel@heimdal.trondhjem.org>
References: <1181808534.2474.7.camel@merlin.linuxcoe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de,
	Kernel Janitors List <kernel-janitors@lists.osdl.org>,
	nfs@lists.sourceforge.net
To: vignesh.babu@wipro.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyrWS-0003W4-OO
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 08:46:08 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+ym5f/EYmRTqCUdcXmtigK64uUwy4F1vY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HyrWU-0004dG-3Q
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 08:46:12 -0700
In-Reply-To: <1181808534.2474.7.camel@merlin.linuxcoe.com>
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

On Thu, 2007-06-14 at 13:38 +0530, vignesh babu wrote:
> Replacing (n & (n-1)) in the context of power of 2 checks
> with is_power_of_2
> 
> Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
> --- 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index ad2b40d..5dca432 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -3,6 +3,7 @@
>   */
>  
>  #include <linux/mount.h>
> +#include <linux/log2.h>
>  
>  struct nfs_string;
>  struct nfs_mount_data;
> @@ -167,7 +168,7 @@ static inline
>  unsigned long nfs_block_bits(unsigned long bsize, unsigned char *nrbitsp)
>  {
>  	/* make sure blocksize is a power of two */
> -	if ((bsize & (bsize - 1)) || nrbitsp) {
> +	if (is_power_of_2(bsize) || nrbitsp) {
>  		unsigned char	nrbits;
>  
>  		for (nrbits = 31; nrbits && !(bsize & (1 << nrbits)); nrbits--)
> 

We don't need the extra test for bsize == 0 that this introduces: bsize
is guaranteed to be at least 1024 or greater.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
