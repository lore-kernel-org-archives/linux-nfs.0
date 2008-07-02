From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Wed, 2 Jul 2008 16:31:30 -0400
Message-ID: <20080702203130.GA24850@fieldses.org>
References: <4869E8AB.4060905@aei.mpg.de> <20080701182250.GB21807@fieldses.org> <486B89F5.9000109@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47273 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757725AbYGBUbb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jul 2008 16:31:31 -0400
In-Reply-To: <486B89F5.9000109-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 02, 2008 at 04:00:21PM +0200, Carsten Aulbert wrote:
> Hi all,
> 
> 
> J. Bruce Fields wrote:
> > 
> > I'm slightly confused--the above is all about server configuration, but
> > the below seems to describe only client problems?
> 
> Well, yes and no. All our servers are clients as well. I.e. we have
> ~1340 nodes which all export a local directory to be cross-mounted.
> 
> >> (1) All our mounts use nfsvers=3 why is rpc.idmapd involved at all?
> > 
> > Are there actually files named "idmap" in those directories?  (Looks to
> > me like they're only created in the v4 case, so I assume those open
> > calls would return ENOENT if they didn't return ENFILE....)
> 
> No there is not and since we are not running v4 yet, we've disabled the
> start for these on all nodes now.
> 
> 
> > 
> >> (2) Why is this daemon growing so extremely large?
> >> # ps aux|grep rpc.idmapd
> >> root      2309  0.1 16.2 2037152 1326944 ?     Ss   Jun30   1:24
> >> /usr/sbin/rpc.idmapd
> > 
> > I think rpc.idmapd has some state for each directory whether they're for
> > a v4 client or not, since it's using dnotify to watch for an "idmap"
> > file to appear in each one.  The above shows about 2k per mount?
> 
> As you have written in your other email, yes that's 2 GByte and I've
> seen boxes where > 500 mounts hung that the process was using all of the
> 8 GByte. So I do think there is a bug.
> 
> OTOH, we still have the problem, that we can only mount up to ~ 350
> remote directories. This one we think we tracked down to the fact that
> the NFS clients refuse to use ports >1023 even though the servers are
> exporting with the "insecure" option. Is there a way to force this?
> Right now the NFS clients use ports 665-1023 (except a few odd ports
> which were in use earlier).
> 
> Any hint for us how we shall proceed and maybe force the clients to also
> use ports > 1023? I think that would solve our problems.

I think the below (untested) would tell the client to stop demanding a
privileged port.

Then you may find you run into other problems, I don't know.  Sounds
like nobody's using this many mounts, so you get to find out what the
next limit is....  But if it works, then maybe someday we should add a
mount option to control this.

--b.


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8945307..51f68cc 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -300,9 +300,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	 * but it is always enabled for rpciod, which handles the connect
 	 * operation.
 	 */
-	xprt->resvport = 1;
-	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
-		xprt->resvport = 0;
+	xprt->resvport = 0;
 
 	clnt = rpc_new_client(args, xprt);
 	if (IS_ERR(clnt))
