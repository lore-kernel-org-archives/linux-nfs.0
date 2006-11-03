From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Forming an NFSv4 clientid
Date: Fri, 3 Nov 2006 13:44:24 -0500
Message-ID: <20061103184424.GE32434@fieldses.org>
References: <76bd70e30611020953v28bc4f40uf5f88f3ec9a0df26@mail.gmail.com>
	<1162494354.6071.15.camel@lade.trondhjem.org>
	<76bd70e30611021124r1437b751x4b251f5925cbad8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gg41q-0003Op-1X
	for nfs@lists.sourceforge.net; Fri, 03 Nov 2006 10:44:34 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gg41m-00063L-Ud
	for nfs@lists.sourceforge.net; Fri, 03 Nov 2006 10:44:35 -0800
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30611021124r1437b751x4b251f5925cbad8b@mail.gmail.com>
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

On Thu, Nov 02, 2006 at 02:24:21PM -0500, Chuck Lever wrote:
> On 11/2/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> >On Thu, 2006-11-02 at 12:53 -0500, Chuck Lever wrote:
> >> While considering what will need to change to support IPv6, I noticed
> >> this logic, which forms the NFSv4 clientid:
> >>
> >>    2927                 setclientid.sc_name_len = 
> >scnprintf(setclientid.sc_name,
> >>    2928                                 sizeof(setclientid.sc_name),
> >> "%s/%u.%u.%u.%u %s %u",
> >>    2929                                 clp->cl_ipaddr,
> >> NIPQUAD(clp->cl_addr.sin_addr),
> >>    2930                                 cred->cr_ops->cr_name,
> >>    2931                                 clp->cl_id_uniquifier);
> >>
> >> When would the contents of cl_ipaddr not be the same as the result of
> >> the NIPQUAD?  For IPv6, the NIPQUAD will have to be replaced, or
> >> removed.  Any suggestions?
> >
> >They are _not_ the same. cl_ipaddr is the client ip address, whereas
> >clp->cl_addr is the server ip address.
> 
> The names of these fields are a little confusing.

Completely agreed.  I stumble over that regularly.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
