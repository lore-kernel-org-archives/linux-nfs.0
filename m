From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Fri, 20 Apr 2007 08:49:25 +0200
Message-ID: <200704200849.27004.olaf.kirch@oracle.com>
References: <17958.48121.280256.493824@notabene.brown>
	<20070419012154.GB19063@javifsp.no-ip.org>
	<17960.11704.321124.641669@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>,
	Javier =?iso-8859-1?q?Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HemxM-0006Y1-He
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 23:51:03 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HemxO-0001Wv-Ry
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 23:50:59 -0700
In-Reply-To: <17960.11704.321124.641669@notabene.brown>
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

On Friday 20 April 2007 05:04, Neil Brown wrote:
> One uses 'getpwnam("rpc")' to find a uid to 'setuid' to.
> This could be a problem is NIS is in use and 'rpc' isn't in
> /etc/passwd - portmap would be need to find the NIS server to check
> for 'rpc' before portmap could start.
> Maybe we should make the uid a compile-time option?

I'd rather make it a command line option. Maximum freedom for users
to shoot themselves in the foot :-)

> The other uses gethostbyname to allow tcpwrappers to provide host-name
> based access control.  This is similarly a potential ground for
> deadlocks, and the man page from Debian explicitly says that isn't
> supported so presumably a Debian maintainer has thought about it.

I agree that this is probably not a very useful patch. But I think
the potential for deadlock is actually rather small. For one,
if you're on a NIS client, I'm not sure the local portmapper is
involved very much at all. For a NIS lookup that starts with a
clean state, you need to get the binding information, which
nowadays is just being read from /var/lib/yp/binding or some
such. The NIS call itself is being placed to the server, and
doesn't involve local portmap either. You could possibly
get yourself into trouble if you have a machine acting as a NIS
server and client at the same time... but that's really kinky
stuff.

> Firstly, registrations made with a privileged port are flagged as
> such, and can only be deregistered with a request from a privileged
> port.  That makes it safe for statd/mountd etc to listen on
> unprivileged ports.

That's nice! However, beware you have to patch rpcinfo so that
rpcinfo -u does a bindresvport when run as root. And *that*
change needs to go into all distros, or you need to get it past
Uli "hell will freeze over first" Drepper.

> Partly to address this, and partly because I think it is a good idea,
> portmap now keeps a copy of it's mapping table in
> /var/run/portmap_mapping (even when it chroots elsewhere) and will
> reload it on restart.  So pmap_dump/pmap_set is no longer needed.

I did this quite a while ago when working at Caldera, and there's
one gotcha I remember quite vividly - you need to reliably find out
whether you're booting (wipe all registrations), or whether the user
is just executing "portmap stop; do_silly_stuff; portmap start". Users
will not accept that "portmap restart" preserves registrations while
the above sequence of commands doesn't. So you need some
init script magic to wipe the file when booting. And once you
solved that, probably some smart person will complain that this
doesn't work when he starts portmap in initrd :-)

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
