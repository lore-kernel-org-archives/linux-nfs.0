From: Neil Brown <neilb@suse.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Fri, 20 Apr 2007 18:02:36 +1000
Message-ID: <17960.29596.729732.864556@notabene.brown>
References: <17958.48121.280256.493824@notabene.brown>
	<20070419012154.GB19063@javifsp.no-ip.org>
	<17960.11704.321124.641669@notabene.brown>
	<200704200849.27004.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>,
	Javier =?iso-8859-1?q?Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Heo5J-0005BF-6B
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 01:03:13 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Heo5K-0005DX-5Q
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 01:03:15 -0700
In-Reply-To: message from Olaf Kirch on Friday April 20
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

On Friday April 20, olaf.kirch@oracle.com wrote:
> On Friday 20 April 2007 05:04, Neil Brown wrote:
> > One uses 'getpwnam("rpc")' to find a uid to 'setuid' to.
> > This could be a problem is NIS is in use and 'rpc' isn't in
> > /etc/passwd - portmap would be need to find the NIS server to check
> > for 'rpc' before portmap could start.
> > Maybe we should make the uid a compile-time option?
> 
> I'd rather make it a command line option. Maximum freedom for users
> to shoot themselves in the foot :-)

Hmmm...

> 
> > The other uses gethostbyname to allow tcpwrappers to provide host-name
> > based access control.  This is similarly a potential ground for
> > deadlocks, and the man page from Debian explicitly says that isn't
> > supported so presumably a Debian maintainer has thought about it.
> 
> I agree that this is probably not a very useful patch. But I think
> the potential for deadlock is actually rather small. For one,
> if you're on a NIS client, I'm not sure the local portmapper is
> involved very much at all. For a NIS lookup that starts with a
> clean state, you need to get the binding information, which
> nowadays is just being read from /var/lib/yp/binding or some
> such. The NIS call itself is being placed to the server, and
> doesn't involve local portmap either. You could possibly
> get yourself into trouble if you have a machine acting as a NIS
> server and client at the same time... but that's really kinky
> stuff.

I guess.  It would be really nice if we could delay doing the hostname
lookup until we find a hostname present in hosts.{allow,deny}.  That
would make it run-time configurable.  I don't think we can do that
though.

> 
> > Firstly, registrations made with a privileged port are flagged as
> > such, and can only be deregistered with a request from a privileged
> > port.  That makes it safe for statd/mountd etc to listen on
> > unprivileged ports.
> 
> That's nice! However, beware you have to patch rpcinfo so that
> rpcinfo -u does a bindresvport when run as root. And *that*
> change needs to go into all distros, or you need to get it past
> Uli "hell will freeze over first" Drepper.

No change needed.  The rpc library already does bindresvport when
creating a client.

> 
> > Partly to address this, and partly because I think it is a good idea,
> > portmap now keeps a copy of it's mapping table in
> > /var/run/portmap_mapping (even when it chroots elsewhere) and will
> > reload it on restart.  So pmap_dump/pmap_set is no longer needed.
> 
> I did this quite a while ago when working at Caldera, and there's
> one gotcha I remember quite vividly - you need to reliably find out
> whether you're booting (wipe all registrations), or whether the user
> is just executing "portmap stop; do_silly_stuff; portmap start". Users
> will not accept that "portmap restart" preserves registrations while
> the above sequence of commands doesn't. So you need some
> init script magic to wipe the file when booting. And once you
> solved that, probably some smart person will complain that this
> doesn't work when he starts portmap in initrd :-)

My understanding is that /var/run is cleared early at bood.  So the
idea was that the choice of path name made all that work
automatically. 

And portmap in initrd?  Just Say No. :-)

Thanks for the comments.
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
