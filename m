From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] SGI 905314 (1/2): make NFSSVC_MAXBLKSIZE depend on PAGE_SIZE
Date: Mon, 1 Dec 2003 09:26:53 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16330.28333.153593.711963@notabene.cse.unsw.edu.au>
References: <3FC742E7.910F518B@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AQa2I-0005xM-00
	for <nfs@lists.sourceforge.net>; Sun, 30 Nov 2003 14:27:26 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AQa2I-00085m-BF
	for nfs@lists.sourceforge.net; Sun, 30 Nov 2003 14:27:26 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gnb@melbourne.sgi.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Mon, 1 Dec 2003 09:26:53 +1100
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Friday November 28
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday November 28, gnb@melbourne.sgi.com wrote:
> G'day,
> 
> SGI bug #905314
> 
> This patch makes NFSSVC_MAXBLKSIZE depend on PAGE_SIZE so that machines
> with large page sizes can take advantage of that feature to serve NFS
> with larger blocksizes, increasing performance and avoiding a fallback
> to synchronous traffic between machines with page sizes greater than 8K.
> Also, documents the actual constraints on NFSSVC_MAXBLKSIZE.
> 
> The patch has been running for some hours now, reading and writing NFSv3
> over UDP on gigabit ethernet between two Altix boxes (16K page sizes) with
> 4G RAM each.  I have verified with ethereal that reads and writes proceed
> in 32K blocks, and performance tests show good throughput for streaming
> reads and writes (although 2.6.0-test8 still does better).

> +#if PAGE_SIZE > (8*1024)
> +#define NFSSVC_MAXBLKSIZE	(32*1024)
> +#elif PAGE_SIZE == (8*1024)
> +#define NFSSVC_MAXBLKSIZE	(16*1024)
> +#else /* 4K pages */
>  #define NFSSVC_MAXBLKSIZE	(8*1024)
> +#endif
>  


What you you think of simply:

   #define NFSSVC_MAXBLKSIZE (PAGE_SIZE * 2)

With a comment "We want this to be large, but we need to be sure that
a kmalloc of this size has a very good chance of succeeding.".

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
