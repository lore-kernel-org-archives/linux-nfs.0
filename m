From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: Forming an NFSv4 clientid
Date: Thu, 2 Nov 2006 14:24:21 -0500
Message-ID: <76bd70e30611021124r1437b751x4b251f5925cbad8b@mail.gmail.com>
References: <76bd70e30611020953v28bc4f40uf5f88f3ec9a0df26@mail.gmail.com>
	<1162494354.6071.15.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GfiAv-0006vP-KV
	for nfs@lists.sourceforge.net; Thu, 02 Nov 2006 11:24:29 -0800
Received: from ug-out-1314.google.com ([66.249.92.168])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GfiAp-0006ME-Ea
	for nfs@lists.sourceforge.net; Thu, 02 Nov 2006 11:24:30 -0800
Received: by ug-out-1314.google.com with SMTP id z38so230052ugc
	for <nfs@lists.sourceforge.net>; Thu, 02 Nov 2006 11:24:22 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1162494354.6071.15.camel@lade.trondhjem.org>
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

On 11/2/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2006-11-02 at 12:53 -0500, Chuck Lever wrote:
> > While considering what will need to change to support IPv6, I noticed
> > this logic, which forms the NFSv4 clientid:
> >
> >    2927                 setclientid.sc_name_len = scnprintf(setclientid.sc_name,
> >    2928                                 sizeof(setclientid.sc_name),
> > "%s/%u.%u.%u.%u %s %u",
> >    2929                                 clp->cl_ipaddr,
> > NIPQUAD(clp->cl_addr.sin_addr),
> >    2930                                 cred->cr_ops->cr_name,
> >    2931                                 clp->cl_id_uniquifier);
> >
> > When would the contents of cl_ipaddr not be the same as the result of
> > the NIPQUAD?  For IPv6, the NIPQUAD will have to be replaced, or
> > removed.  Any suggestions?
>
> They are _not_ the same. cl_ipaddr is the client ip address, whereas
> clp->cl_addr is the server ip address.

The names of these fields are a little confusing.  The structure is
"nfs_client" and the field is "cl_addr", yet this is the address of
the remote peer.  I'd like cl_srvaddr or cl_remote_addr better.

Not much distinction for the "cl_ipaddr" field either.  Maybe
cl_formattedlocaladdr, although ugly, would be more descriptive.  Or
following the precedent set in the RPC client: cl_local_addrbuf?

> Just replace clp->cl_addr with your usual "print server address"
> routine, increase the size of cl_ipaddr so that it can take an IPv6
> string, and adjust the size of setclientid.sc_name accordingly.

Yep, sounds good.

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
