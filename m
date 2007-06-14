From: Yoann Padioleau <padator@wanadoo.fr>
Subject: Re: [KJ] [PATCH]is_power_of_2-nfs/internal.h
Date: Thu, 14 Jun 2007 17:59:47 +0200
Message-ID: <871wger0gc.fsf@wanadoo.fr>
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
	id 1Hyrjp-0004sY-RG
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 08:59:58 -0700
Received: from sicnat2.emn.fr ([193.54.76.193] helo=ron.emn.fr)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hyrjq-0000Xq-In
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 09:00:01 -0700
In-Reply-To: <1181808534.2474.7.camel@merlin.linuxcoe.com> (vignesh babu's
	message of "Thu, 14 Jun 2007 13:38:54 +0530")
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

vignesh babu <vignesh.babu@wipro.com> writes:

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

Did I miss something but why in this case it's not 

+	if (!is_power_of_2(bsize) || nrbitsp) {

?


>  		unsigned char	nrbits;
>  
>  		for (nrbits = 31; nrbits && !(bsize & (1 << nrbits)); nrbits--)
>
> -- 
> Vignesh Babu BM 
> _____________________________________________________________ 
> "Why is it that every time I'm with you, makes me believe in magic?"
>
> _______________________________________________
> Kernel-janitors mailing list
> Kernel-janitors@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/kernel-janitors


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
