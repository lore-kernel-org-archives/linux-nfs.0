From: James Pearson <james-p@moving-picture.com>
Subject: Re: [PATCH] kNFSd - 4 of 6 - Make sure dnotify events happen for
 NFS read and write.
Date: Fri, 16 Jan 2004 14:31:53 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4007F5D9.BEB0596B@moving-picture.com>
References: <E1AhIle-0002ne-00@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AhV16-00062Y-MJ
	for nfs@lists.sourceforge.net; Fri, 16 Jan 2004 06:32:08 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AhV16-0002Ki-6T
	for nfs@lists.sourceforge.net; Fri, 16 Jan 2004 06:32:08 -0800
To: NeilBrown <neilb@cse.unsw.edu.au>
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

With this patch (applied to a generic 2.6.1 kernel tree), 'make
install_modules' complains with:

WARNING: /lib/modules/2.6.1/kernel/fs/nfsd/nfsd.ko needs unknown symbol
dnotify_parent

Adding:

EXPORT_SYMBOL(dnotify_parent);

to fs/dnotify.c appears to fix this.

James Pearson


NeilBrown wrote:
> 
> Based on code from  Terje Malmedal <terje.malmedal@usit.uio.no>
> 
>  ----------- Diffstat output ------------
>  ./fs/nfsd/vfs.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
> --- ./fs/nfsd/vfs.c~current~    2004-01-16 12:20:18.000000000 +1100
> +++ ./fs/nfsd/vfs.c     2004-01-16 12:21:25.000000000 +1100
> @@ -43,6 +43,7 @@
>  #endif /* CONFIG_NFSD_V3 */
>  #include <linux/nfsd/nfsfh.h>
>  #include <linux/quotaops.h>
> +#include <linux/dnotify.h>
> 
>  #include <asm/uaccess.h>
> 
> @@ -680,6 +681,7 @@ nfsd_read(struct svc_rqst *rqstp, struct
>                 nfsdstats.io_read += err;
>                 *count = err;
>                 err = 0;
> +               dnotify_parent(file.f_dentry, DN_ACCESS);
>         } else
>                 err = nfserrno(err);
>  out_close:
> @@ -745,9 +747,11 @@ nfsd_write(struct svc_rqst *rqstp, struc
>         /* Write the data. */
>         oldfs = get_fs(); set_fs(KERNEL_DS);
>         err = vfs_writev(&file, vec, vlen, &offset);
> -       if (err >= 0)
> -               nfsdstats.io_write += cnt;
>         set_fs(oldfs);
> +       if (err >= 0) {
> +               nfsdstats.io_write += cnt;
> +               dnotify_parent(file.f_dentry, DN_MODIFY);
> +       }
> 
>         /* clear setuid/setgid flag after write */
>         if (err >= 0 && (inode->i_mode & (S_ISUID | S_ISGID))) {
> 
> -------------------------------------------------------
> The SF.Net email is sponsored by EclipseCon 2004
> Premiere Conference on Open Tools Development and Integration
> See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
> http://www.eclipsecon.org/osdn
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
