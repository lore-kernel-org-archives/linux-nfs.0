From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] fix compile warning in fs/nfsd/nfs4xdr.c, 2.6.0-t5-cvs
Date: Tue, 23 Sep 2003 09:34:18 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16239.34554.547683.65579@notabene.cse.unsw.edu.au>
References: <20030921080923.GC4938@actcom.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1aCX-00006l-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 16:34:41 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1aCW-0003pf-J9
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 16:34:40 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <mulix@mulix.org>) (for <linux-kernel@vger.kernel.org>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Tue, 23 Sep 2003 09:34:31 +1000
To: Muli Ben-Yehuda <mulix@mulix.org>
In-Reply-To: message from Muli Ben-Yehuda on Sunday September 21
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

On Sunday September 21, mulix@mulix.org wrote:
> When compiling fs/nfsd/nfs4xdr.c, I get a warning:
> 
> fs/nfsd/nfs4xdr.c: In function `nfsd4_encode_open':
> fs/nfsd/nfs4xdr.c:1773: warning: `return' with a value, in function
> returning void
> 
> This patch fixes it. I'm not 100% sure about it, but it seems
> correct, and the return value is ignored anyway... 

As the return value is ignored, we really shouldn't be returning one.
I have just sent a patch to Linus which fixes this problem
differently: by making nfsd4_encode_open never return anything.

Thanks,
NeilBrown

> 
> diff --exclude-from /home/muli/p/dontdiff -Naur ../linux-2.5/fs/nfsd/nfs4xdr.c 2.6.0-t5-Werror/fs/nfsd/nfs4xdr.c
> --- ../linux-2.5/fs/nfsd/nfs4xdr.c	Tue Sep  2 12:51:06 2003
> +++ 2.6.0-t5-Werror/fs/nfsd/nfs4xdr.c	Sun Sep 21 10:18:19 2003
> @@ -1709,13 +1709,13 @@
>  }
>  
>  
> -static void
> +static int
>  nfsd4_encode_open(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_open *open)
>  {
>  	ENCODE_HEAD;
>  
>  	if (nfserr)
> -		return;
> +		return nfserr;
>  
>  	RESERVE_SPACE(36 + sizeof(stateid_t));
>  	WRITE32(open->op_stateid.si_generation);
> 
> -- 
> Muli Ben-Yehuda
> http://www.mulix.org
> 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
