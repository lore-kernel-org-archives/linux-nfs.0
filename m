From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 004 of 19] knfsd: lockd: introduce nsm_handle
Date: Thu, 31 Aug 2006 23:20:29 -0700
Message-ID: <20060831232029.b003e8a7.akpm@osdl.org>
References: <20060901141639.27206.patches@notabene>
	<1060901043825.27464@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ2OF-0005xj-D1
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 23:20:31 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1GJ2OF-0006tM-TG
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 23:20:32 -0700
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

> +nsm_release(struct nsm_handle *nsm)
> +{
> +	if (!nsm)
> +		return;
> +	if (atomic_read(&nsm->sm_count) == 1) {
> +		down(&nsm_sema);
> +		if (atomic_dec_and_test(&nsm->sm_count)) {
> +			list_del(&nsm->sm_link);
> +			kfree(nsm);
> +		}
> +		up(&nsm_sema);
> +	}
> +}

That's weird-looking.  Are you sure?  afaict, if ->sm_count ever gets a
value of 2 or more, it's unfreeable.  

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
