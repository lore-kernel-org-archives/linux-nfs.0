From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Make NFS userspace and server directories cookies independant
 [patch, fc3, 2.6.10-1.766_FC3]
Date: Mon, 21 Mar 2005 19:22:16 -0500
Message-ID: <1111450936.10980.55.camel@lade.trondhjem.org>
References: <20050321162142.GB46055@dspnet.fr.eu.org>
	 <1111427218.10508.27.camel@lade.trondhjem.org>
	 <20050322000210.GA4681@dspnet.fr.eu.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Hack inc." <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDXAN-00071h-Ki
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 16:22:39 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDXAM-0008Dz-Fd
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 16:22:39 -0800
To: Olivier Galibert <galibert@pobox.com>
In-Reply-To: <20050322000210.GA4681@dspnet.fr.eu.org>
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

ty den 22.03.2005 Klokka 01:02 (+0100) skreiv Olivier Galibert:
> On Mon, Mar 21, 2005 at 12:46:58PM -0500, Trond Myklebust wrote:

> +	if (filp->f_pos == ctx->dir_pos)
> +		desc->target_cookie = ctx->dir_cookie;
> +	else
> +		desc->target_cookie = 0;

This sort of thing worries me: I think we can do better by hooking
lseek() on directories. I'll see what I can do.

Cheers,
  Trond
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
