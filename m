From: Olaf Kirch <okir@lst.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Wed, 25 Apr 2007 22:14:02 +0200
Message-ID: <200704252214.03069.okir@lst.de>
References: <17958.48121.280256.493824@notabene.brown>
	<200704251356.35926.okir@lst.de> <462F7769.4080304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgnsP-00027A-E0
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 13:14:09 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgnsR-00045U-Gv
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 13:14:12 -0700
In-Reply-To: <462F7769.4080304@redhat.com>
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

On Wednesday 25 April 2007 17:44, you wrote:
> It is also a distinct possibility that the folks maintaining the TI-RPC
> code which is in common use may have fixed a few bugs since the Linux
> source bases, either the glibc or tirpc versions, were acquired.  I
> think that it would be good to have those, _plus_ any bugs which may
> already been fixed in the glibc version.  Wouldn't you agree?

Which is why I did this comparison of the code today. In summary,
in the common files there's stuff in tirpc that  glibc misses, but the
other way round there's just more.

I don't say tirpc is bad. What I say is, it's better to handle this the way
we deal with changes to the kernel: start with what you have, and
which you know works well. Add to it, until you have the functionality
you want. On the way, you may find out there's better ways of
solving things that you anticipated. If you run into sudden problems,
you can bisect.

For instance, I would rather like to see the current functionality
extended transparently:

 -	svc{tcp,udp}_create create an IPv6 socket rather than
	an IPv4 socket by default. Try to use rpcbind style
	registrations, but fall back to portmap if it doesn't
	exist. This needs some extra magic to handle
	IPv6 mapped IPv4 addresses in svc_getcaller, but that
	should almost do it

 -	clnt{udp,tcp}_create needs some magic to find out
	whether to use IPv6 or IPv4. The ability to create an
	IPv6 socket doesn't mean anything; we probably need
	a config mechanism somewhere. Else you will end up
	with an awful lot of timeouts (ask the web browser folks
	about their IPv6 pains). But it doesn't have to be something
	complicated like netconf; it's more like an IPv6 on/off
	switch, and a "prefer IPv4/IPv6" switch.

	Good heuristics to decide whether to try IPv6
	 -	ability to open an IPv6 socket
	 -	DNS returns IPv6 addrs for the remote host
	 -	there's an rpcbind on the server host, and it
		returns udp6/tcp6 registrations
	 -	if it's a global address, we need an interface
		with a global prefix
	 -	if it's a link local prefix, just try it.

 -	make clnt_create understand udp6/tcp6
 
This is the stuff we can do today, with little overhead, to bring
IPv6 support to the distros without making their choices
difficult. All we need is

 -	rpcbind
 -	rpcb client in the sunrpc lib
 -	make bindresvport ipv6 aware
 -	extended functionality as descrived above

This will not be perfect, but it would be a start. From there,
you can proceed by fixing clnt_broadcast to deal with
IPv6; you can add netconf if you want, and the whole
tirpc API if you wish.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
