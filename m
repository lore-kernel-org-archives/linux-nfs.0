From: "Chuck Lever" <chucklever@gmail.com>
Subject: Forming an NFSv4 clientid
Date: Thu, 2 Nov 2006 12:53:14 -0500
Message-ID: <76bd70e30611020953v28bc4f40uf5f88f3ec9a0df26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gfgkj-0006WN-Iu
	for nfs@lists.sourceforge.net; Thu, 02 Nov 2006 09:53:21 -0800
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gfgkj-00026m-Fz
	for nfs@lists.sourceforge.net; Thu, 02 Nov 2006 09:53:22 -0800
Received: by ug-out-1314.google.com with SMTP id z38so204800ugc
	for <nfs@lists.sourceforge.net>; Thu, 02 Nov 2006 09:53:15 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>
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

While considering what will need to change to support IPv6, I noticed
this logic, which forms the NFSv4 clientid:

   2927                 setclientid.sc_name_len = scnprintf(setclientid.sc_name,
   2928                                 sizeof(setclientid.sc_name),
"%s/%u.%u.%u.%u %s %u",
   2929                                 clp->cl_ipaddr,
NIPQUAD(clp->cl_addr.sin_addr),
   2930                                 cred->cr_ops->cr_name,
   2931                                 clp->cl_id_uniquifier);

When would the contents of cl_ipaddr not be the same as the result of
the NIPQUAD?  For IPv6, the NIPQUAD will have to be replaced, or
removed.  Any suggestions?

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
