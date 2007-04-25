From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Wed, 25 Apr 2007 10:56:01 +0200
Message-ID: <200704251056.03664.olaf.kirch@oracle.com>
References: <17958.48121.280256.493824@notabene.brown>
	<20070424171708.GA7936@infradead.org> <462E43CC.6040806@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgdJT-0000Db-ID
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 01:57:23 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgdJT-0003Ee-Rr
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 01:57:26 -0700
In-Reply-To: <462E43CC.6040806@RedHat.com>
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

On Tuesday 24 April 2007 19:52, Steve Dickson wrote:
> In theory yes...  but unfortunately Transport Independent
> RPC code is much different than the RPC we have in glibc.

Still, there's a whole load of shared code, and this is where
I agree with Christoph that it would be foolish to throw away
the work that went into the glibc code. The buffer overflow fix
I mentioned is just one such thing - I did a diff of the files
common in glibc and tirpc, and here are some of the
things I found.

 -	glibc authunix_create_default works if the process has
	more than NGRPS gids. tirpc wil fail

 -	glibc tries to be more multithread friendly, by using
	things like gethostbyname_r instead of gethostbyname.
	tirpc doesn't.

 -	it seems that tirpc unconditionally requires rpcbind,
	even for applications that still use pmap_set and
	friends. In the interest of a smooth transition, applications
	using the old interface should be able to expect the
	old behavior.

 -	tirpc does truly bizarre things, eg in clnt_raw.c
	it declares a local variable, and then acquires
	a mutex to check this local variable for NULL:

	       mutex_lock(&clntraw_lock);
	       if (clp == NULL) {
	               mutex_unlock(&clntraw_lock);
	               return (RPC_FAILED);
	       }
	       mutex_unlock(&clntraw_lock);

 -	tirpc has a mechanism that lets you register
	server side auth flavors dynamically; libc
	doesn't.

 -	glibc switched to poll(), whereas tirpc still uses
	select with all its limitations

 -	in tirpc, svc.c seems to be thread safe, whereas
	glibc isn't.

 -	tirpc lets the application control the maximum record
	size, making DoS attacks just a little harder.

 -	in tirpc, xdr_mem.c has different ops for aligned vs
	unaligned buffers, for what it's worth.

 -	in tirpc, clnt_sperror uses snprintf to avoid buffer overflows,
	but gets it all wrong wrt the return value of snprintf.

 -	tirpc is K&R all over the place, while glibc is mostly
	cleaned up (not everywhere though)

 -	tirpc bindresvport is IPv6 aware, but has a bug: if the
	caller passes a sockaddr with sin_port/sin6_port set,
	the routine will actually bind to htons(port).
	the libc bindresvport implementation also has a small
	optimization in that it will continue searching where the
	previous call to bindresvport left off, rather than starting
	all over from 600.

 -	the authunix code in tirpc assumes sizeof(gid_t)
	equals sizeof(int)

 -	the glibc RPC client side seems to be thread safe, whereas
	tirpc seems to be lacking in some areas (see rpc_thread.c)

I stopped reading the code after an hour, but I think this list could
be extended quite a bit.

So from my POV the decision between tirpc and glibc rpc isn't
that clear-cut. TIRPC clearly needs some work before distros
should consider using it.

> Again, I realize this code is very raw, but the only way
> to bring it up to speed (something I really thing we want
> to do) is using it and making it available to the community.

Well, there's one thing that makes the transition very tricky.
I looked into this while I was still with Novell, because we had
a request from the Bull folks to include tirpc. If you include
tirpc, you either have to remove all RPC code from glibc
at the same time, and fix up all applications linking against
this code. Downside: no binary compatibility, and the customers
who paid a lot of money for some commercial app will hate
you if an OS upgrade requires them to buy new licenses.

The other approach is to make sure that you provide *any*
RPC related symbol glibc provides, in tirpc as well. Even
if it does nothing, and just errors out. Otherwise you may end
up with somebody's application linked against tirpc, but it
calls some forgotten little function in glibc and falls over.
This is tricky too.

This is why I had very strong reservations about including
tirpc in SLES.

I'm wondering whether all that hassle is really worth
it. There should be a way to IPv6 enable the glibc RPC
implementation without having to go to TIRPC. Yes,
Solaris requires rpcbind and such in order to do IPv6.
But that's not the same as replacing glibc's sunrpc code.

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
