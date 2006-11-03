From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Forming an NFSv4 clientid
Date: Fri, 03 Nov 2006 13:47:22 -0500
Message-ID: <1162579642.5629.41.camel@lade.trondhjem.org>
References: <76bd70e30611020953v28bc4f40uf5f88f3ec9a0df26@mail.gmail.com>
	<1162494354.6071.15.camel@lade.trondhjem.org>
	<76bd70e30611021124r1437b751x4b251f5925cbad8b@mail.gmail.com>
	<20061103184424.GE32434@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gg44w-0003fW-Uy
	for nfs@lists.sourceforge.net; Fri, 03 Nov 2006 10:47:47 -0800
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gg44t-0001pw-Jp
	for nfs@lists.sourceforge.net; Fri, 03 Nov 2006 10:47:48 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061103184424.GE32434@fieldses.org>
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

On Fri, 2006-11-03 at 13:44 -0500, J. Bruce Fields wrote:
> On Thu, Nov 02, 2006 at 02:24:21PM -0500, Chuck Lever wrote:
> > On 11/2/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > >On Thu, 2006-11-02 at 12:53 -0500, Chuck Lever wrote:
> > >> While considering what will need to change to support IPv6, I noticed
> > >> this logic, which forms the NFSv4 clientid:
> > >>
> > >>    2927                 setclientid.sc_name_len = 
> > >scnprintf(setclientid.sc_name,
> > >>    2928                                 sizeof(setclientid.sc_name),
> > >> "%s/%u.%u.%u.%u %s %u",
> > >>    2929                                 clp->cl_ipaddr,
> > >> NIPQUAD(clp->cl_addr.sin_addr),
> > >>    2930                                 cred->cr_ops->cr_name,
> > >>    2931                                 clp->cl_id_uniquifier);
> > >>
> > >> When would the contents of cl_ipaddr not be the same as the result of
> > >> the NIPQUAD?  For IPv6, the NIPQUAD will have to be replaced, or
> > >> removed.  Any suggestions?
> > >
> > >They are _not_ the same. cl_ipaddr is the client ip address, whereas
> > >clp->cl_addr is the server ip address.
> > 
> > The names of these fields are a little confusing.
> 
> Completely agreed.  I stumble over that regularly.

I'm always willing to accept patches :-)

Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
