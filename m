From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: open O_EXCL works?
Date: Tue, 22 Mar 2005 07:46:09 -0300
Message-ID: <20050322073459.BE83.BRANDEN@terra.com.br>
References: <20050321181858.BE73.BRANDEN@terra.com.br> <1111449675.10980.50.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDgsh-0003Yl-Nu
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 02:45:03 -0800
Received: from loncoche.terra.com.br ([200.154.55.229])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDgsg-0002vf-55
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 02:45:03 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1111449675.10980.50.camel@lade.trondhjem.org>
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


Hi again.

* Mon, 21 Mar 2005 19:01:15 -0500, Trond Myklebust <trond.myklebust@fys.uio.no>:
> For newer kernels, you should read all about the NFS cache consistency
> model on
> 
>    http://nfs.sourceforge.net/#faq_a8

Which versions? 2.6 and newer? As I read it on the FAQ, close-to-open
consistency was introduced in 2.4.20 (although I'm with 2.4.9, but I
believe it's really patched, as it's a RedHat thing).

> On an old kernel, like 2.4.20, you will also have to set the "noac"
> mount option. It makes everything very slow, but it is necessary in
> order to compensate for the lack of close-to-open cache consistency.

Gee, do I need to completely disable attribute caching for that? I
really can't afford it, the perofmance penalty for it is too expensive...
Isn't the "nocto" enough already (as I read it, "cto" is for
"close-to-open")?

       nocto          Suppress the retrieval of new attributes when creating a file.

Isn't there a safe and cheap way to use a lock file that works on NFSv3
on a 2.4.9 kernel?

Thanks,
Filipe



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
