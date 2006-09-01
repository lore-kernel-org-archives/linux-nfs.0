From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 004 of 19] knfsd: lockd: introduce nsm_handle
Date: Thu, 31 Aug 2006 23:17:03 -0700
Message-ID: <20060831231703.78c99b60.akpm@osdl.org>
References: <20060901141639.27206.patches@notabene>
	<1060901043825.27464@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ2Kw-0005iN-Cn
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 23:17:06 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1GJ2Kv-0002Ug-Sb
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 23:17:07 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060901043825.27464@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 1 Sep 2006 14:38:25 +1000
NeilBrown <neilb@suse.de> wrote:

> +static DECLARE_MUTEX(nsm_sema);
> ...
> +	down(&nsm_sema);

Next you'll all be wearing bell-bottomed jeans?

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
