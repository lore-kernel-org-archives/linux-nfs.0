From: Oliver Tennert <tennert@science-computing.de>
Subject: Re: PATCH [NFSd] NFSv3/TCP
Date: Fri, 7 May 2004 09:52:32 +0200 (CEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0405070949160.5549-100000@picard.science-computing.de>
References: <409B3930.9B0C9659@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, <linux-kernel@vger.kernel.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263271AbUEGHwz@vger.kernel.org>
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <409B3930.9B0C9659@melbourne.sgi.com>
List-ID: <nfs.lists.sourceforge.net>


As it does not any changes for say a i386 architecture, I cannot see why
after that my lockups should go away.

Are lockups no known problem at all? Am I the only one experiencing them?
They _definitely_ went away for me with NFSSVC_MAXBLKSIZE equal 32k, even
under high IO pressure.

Regards

Oliver


On Fri, 7 May 2004, Greg Banks wrote:

>
> Then please consider this a resend.  I'll appreciate any guidance
> about proper submission.
>
> This patch has been in SGI's ProPack kernel for 6 months and resulted
> in a significant improvement in NFS throughput at a number of customer
> sites.
>
> --- /usr/tmp/TmpDir.16250-0/linux/linux/include/linux/nfsd/const.h_1.5	Fri May  7
> 17:20:22 2004
> +++ /usr/tmp/TmpDir.16250-0/linux/linux/include/linux/nfsd/const.h	Fri May  7
> 17:20:22 2004
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
>
>
> Greg.
> --
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.
>

__
________________________________________creating IT solutions

Dr. Oliver Tennert			science + computing ag
phone   +49(0)7071 9457-598		Hagellocher Weg 71-75
fax     +49(0)7071 9457-411		D-72070 Tuebingen, Germany
O.Tennert@science-computing.de		www.science-computing.de
