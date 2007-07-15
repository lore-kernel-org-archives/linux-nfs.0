From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] have NFSv4 nfs sockets bind to the callback
	address
Date: Sun, 15 Jul 2007 09:42:30 -0400
Message-ID: <1184506950.6274.10.camel@heimdal.trondhjem.org>
References: <20070713110644.4758124a.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IA4Mu-0003DZ-7T
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 06:42:36 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+u5FN4ZDTBFiO8t6LDv7VTUv/ZR42y99U=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IA4Mx-0005mb-Es
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 06:42:40 -0700
In-Reply-To: <20070713110644.4758124a.jlayton@redhat.com>
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

On Fri, 2007-07-13 at 11:06 -0400, Jeff Layton wrote:
> It's been pointed out to me that some clients have complicated routing,
> or have HA requirements that require that they prefer particular source
> addresses for their NFS sockets. Here's one such scheme that was
> described to me:
> 
> -------[snip]--------
> -  two interfaces, each on different subnets (say eth0 and eth1)
> -  an lo:foo virtual interface with a /32 bit netmask (in a different
>    IP range than the above two).
> -  multiple, equal cost, default routes out each of the two real
>    interfaces
> -  advertise the /32 lo:foo IP simultaneously, VIA RIPv2, out bot eth0
>    and eth1 or
> -  add equal cost static routes, on the router, to the lo:foo IP via
>    eth0 and eth1
> -  you would need something to monitor the routers and remove the route
>    on the host if one of them goes down.
> 
> without any patch, when you mount, the above configured NFS client will
> use one of the eth0/1 IPs, never the lo:foo IP as the src.  Then if the
> router out the int it chose to use goes down, it will never recover
> cause the NFS server only knows it via that addr.  but if you mounted
> the NFS volume using the src addr of lo:foo, it will "just work"
> -------[snip]--------
> 
> After looking at some different ways to handle this, I think the best
> scheme would be to expand the scope of the NFSv4 "clientaddr=" option
> so that the nfs socket is also bound to the same local address.
> 
> Now that Frank V.M. has done the heavy lifting to allow client side
> sockets to bind to a specified address, this patch is fairly simple to
> implement for NFSv4. If this is acceptable we might consider doing
> the same for v2/3, but I'd prefer to wait until Chuck's string-based
> options patch is fully in place rather than having to change the
> nfs_mount_options struct.
> 
> Thoughts?

No. "clientaddr" is supposed to advertise the _callback_ address for
NFSv4. i.e. it advertises the address on which the callback server is
listening.

Consider a NAT setup, say, on which you have set up an incoming tunnel
and need to advertise that to the server. It should be clear that this
address (being on the outside of the NAT) has absolutely nothing to do
with the address on which you want to bind the outgoing connections.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
