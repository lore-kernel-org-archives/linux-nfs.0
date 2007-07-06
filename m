From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [PATCH 2/3] SUNRPC client: add interface for binding to
	a	local address
Date: Fri, 6 Jul 2007 18:31:48 +0200
Message-ID: <20070706163148.GA19489@janus>
References: <20070705152634.GC6603@janus>
	<1183729576.6463.29.camel@heimdal.trondhjem.org>
	<468E6269.8080004@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6qig-0000fl-Rl
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 09:31:49 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I6qik-0000Bz-1m
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 09:31:50 -0700
In-Reply-To: <468E6269.8080004@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Jul 06, 2007 at 11:40:25AM -0400, Chuck Lever wrote:
> Trond Myklebust wrote:
> >On Thu, 2007-07-05 at 17:26 +0200, Frank van Maarseveen wrote:
> >>@@ -1146,31 +1147,33 @@ static void xs_set_port(struct rpc_xprt 
> >> 	sap->sin_port = htons(port);
> >> }
> >> 
> >>-static int xs_bindresvport(struct sock_xprt *transport, struct socket 
> >>*sock)
> >>+static int xs_bind(struct sock_xprt *transport, struct socket *sock)
> >> {
> >> 	struct sockaddr_in myaddr = {
> >> 		.sin_family = AF_INET,
> >> 	};
> >>+	struct sockaddr_in *sa;
> >> 	int err;
> >> 	unsigned short port = transport->port;
> >
> >Instead of forcing two tests of transport->xprt.resvport per loop, why
> >not just set port to 0 in the case of !transport->xprt.resvport?
> 
> This logic seems unnecessarily complicated to me, too.  I'm not so 
> concerned about the loop optimization, but it certainly isn't immediate 
> from looking at these changes exactly what is going on here in the two 
> important cases ("yes we want a reserved port" and "no, any old port 
> will do, thanks").  Anything that clarifies this would be welcome, but 
> I'd encourage code clarity over just adding a comment or two.

ok, I'll rephrase it a bit.

[snip]
> >>-	dprintk("RPC:       can't bind to reserved port (%d).\n", -err);
> >>+	dprintk("RPC:       xs_bind "NIPQUAD_FMT":%u: %d\n",
> >>+		NIPQUAD(myaddr.sin_addr), port, err);
> >
> >Hmm... I thought you said this was IPv6 clean :-)
> 
> Well, IPv6 uses a separate xs_bindresvport routine, so IPv4-specific 
> stuff can be added in here with aplomb.  We just have to remember to 
> make Frank's changes to the xs_bindresvport6 when it is integrated.
> 
> Frank, can you make this debugging message a little more friendly?

ok,

I'll first create a cleanup patch as Trond suggested.


-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
