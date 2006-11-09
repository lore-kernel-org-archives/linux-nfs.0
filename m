From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 01/12] SUNRPC: allow creating an RPC service
	without registering with portmapper
Date: Thu, 9 Nov 2006 14:39:13 +1100
Message-ID: <17746.41697.209294.695419@cse.unsw.edu.au>
References: <20061101180808.14581.98744.stgit@schiele.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gi0ky-0005NY-0t
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 19:39:12 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gi0kx-0005hv-NC
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 19:39:13 -0800
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: message from Chuck Lever on Wednesday November 1
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

On Wednesday November 1, chuck.lever@oracle.com wrote:
> -	ret = svc_makesock(serv, IPPROTO_TCP, nfs_callback_set_tcpport);
> +	ret = svc_makesock_noregister(serv, IPPROTO_TCP, nfs_callback_set_tcpport);
>  	if (ret < 0)
>  		goto out_destroy;
> -	if (!list_empty(&serv->sv_permsocks)) {
> -		svsk = list_entry(serv->sv_permsocks.next,
> -				struct svc_sock, sk_list);
> -		nfs_callback_tcpport = ntohs(inet_sk(svsk->sk_sk)->sport);
> -		dprintk ("Callback port = 0x%x\n", nfs_callback_tcpport);
> -	} else
> -		BUG();
> +	if (list_empty(&serv->sv_tempsocks)) {
> +		ret = -ENOMEM;
> +		goto out_destroy;
> +	}
> +	svsk = list_entry(serv->sv_tempsocks.next, struct svc_sock, sk_list);
> +	nfs_callback_tcpport = ntohs(inet_sk(svsk->sk_sk)->sport);
> +	dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);

This is somewhat ugly (both old and new code).
Can we just get svc_makesock* to take an 'int *' rather than an 'int'
so that it can return a dynamically allocated port number?

Also I'm not very comfortable with the fact that sockets that aren't
registered become ipso-facto temporary sockets.  They might get closed
due to age.

Maybe we should pull the call to svc_register out of svc_setup_socket
and change the pmap_register flag to is_permanent or similar.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
