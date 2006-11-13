From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 02/13] SUNRPC: allow creating an RPC service
	without registering with portmapper
Date: Mon, 13 Nov 2006 16:50:54 -0500
Message-ID: <76bd70e30611131350p2f03990ifcef72039c600dd9@mail.gmail.com>
References: <20061113125640.4435.11957.stgit@localhost.localdomain>
	<20061113125757.4435.27983.stgit@localhost.localdomain>
	<1163453528.5699.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gjjhj-0006U6-K9
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 13:51:00 -0800
Received: from ug-out-1314.google.com ([66.249.92.174])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gjjhj-0004xW-OH
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 13:51:01 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1214790ugc
	for <nfs@lists.sourceforge.net>; Mon, 13 Nov 2006 13:50:55 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1163453528.5699.9.camel@lade.trondhjem.org>
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

On 11/13/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Mon, 2006-11-13 at 07:57 -0500, Chuck Lever wrote:
> > +     ret = svc_makesock(serv, IPPROTO_TCP, nfs_callback_set_tcpport,
> > +                             (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY));
>
> Why are you requesting that this socket to be put on the sv_tempsocks
> list? That has got to be wrong.

Yeah, that's probably a bug.  The way svc_makesock() currently works,
if you don't register the socket with the local port mapper, it makes
it a temporary socket.  I'm just carrying that behavior over, and as
you point out, it's not correct; we want ANONYMOUS only here.

I'll send out a new version of this patch with that fixed.

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
