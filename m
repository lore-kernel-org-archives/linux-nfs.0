From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Forming an NFSv4 clientid
Date: Thu, 02 Nov 2006 14:05:54 -0500
Message-ID: <1162494354.6071.15.camel@lade.trondhjem.org>
References: <76bd70e30611020953v28bc4f40uf5f88f3ec9a0df26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GfhtS-000596-ST
	for nfs@lists.sourceforge.net; Thu, 02 Nov 2006 11:06:29 -0800
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GfhtQ-0000Rt-DS
	for nfs@lists.sourceforge.net; Thu, 02 Nov 2006 11:06:27 -0800
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30611020953v28bc4f40uf5f88f3ec9a0df26@mail.gmail.com>
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

On Thu, 2006-11-02 at 12:53 -0500, Chuck Lever wrote:
> While considering what will need to change to support IPv6, I noticed
> this logic, which forms the NFSv4 clientid:
> 
>    2927                 setclientid.sc_name_len = scnprintf(setclientid.sc_name,
>    2928                                 sizeof(setclientid.sc_name),
> "%s/%u.%u.%u.%u %s %u",
>    2929                                 clp->cl_ipaddr,
> NIPQUAD(clp->cl_addr.sin_addr),
>    2930                                 cred->cr_ops->cr_name,
>    2931                                 clp->cl_id_uniquifier);
> 
> When would the contents of cl_ipaddr not be the same as the result of
> the NIPQUAD?  For IPv6, the NIPQUAD will have to be replaced, or
> removed.  Any suggestions?

They are _not_ the same. cl_ipaddr is the client ip address, whereas
clp->cl_addr is the server ip address.

Just replace clp->cl_addr with your usual "print server address"
routine, increase the size of cl_ipaddr so that it can take an IPv6
string, and adjust the size of setclientid.sc_name accordingly.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
