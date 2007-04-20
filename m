From: Neil Brown <neilb@suse.de>
Subject: Portmap - was Re: Does mountd/statd really need to listen on
	a privileged port??
Date: Fri, 20 Apr 2007 13:04:24 +1000
Message-ID: <17960.11704.321124.641669@notabene.brown>
References: <17958.48121.280256.493824@notabene.brown>
	<20070419012154.GB19063@javifsp.no-ip.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Olaf Kirch <olaf.kirch@oracle.com>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>,
	Matthias Koenig <mkoenig@novell.com>,
	Javier =?iso-8859-1?Q?Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HejQk-0001Rt-4X
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 20:05:02 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HejQm-0007si-0c
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 20:05:04 -0700
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


Well, the consensus seems to be that a new 'upstream' would not be a
bad thing, but that including it in nfs-utils might not be the best
idea.

I can live with that, and would like to nominate myself as the new
upstream source for 'portmap'.  Does anyone object?

I have created a git repository that can be accessed via:
   git://neil.brown.name/portmap
or
   http://neil.brown.name/git?p=portmap  (for browsing).

It starts with the '5beta' tarball that both SuSE and Debian use
(Fedora uses a slightly older version 4 tarball).
It then adds a host of fixes which cover almost everything I can find
in the Debian, SuSE, and Fedora packages.
The only conflict was the SuSE and Fedora chose a syslog facility of
'AUTH' while Debian chose 'DAEMON' (the original tarball has 'MAIL').
'DAEMON' makes most sense to me, so that is in the .git.

There are two patches from Fedora that I have not included.

One uses 'getpwnam("rpc")' to find a uid to 'setuid' to.
This could be a problem is NIS is in use and 'rpc' isn't in
/etc/passwd - portmap would be need to find the NIS server to check
for 'rpc' before portmap could start.
Maybe we should make the uid a compile-time option?

The other uses gethostbyname to allow tcpwrappers to provide host-name
based access control.  This is similarly a potential ground for
deadlocks, and the man page from Debian explicitly says that isn't
supported so presumably a Debian maintainer has thought about it.

Maybe we could add a compile-time option to enable this if Fedora
really wants it.

Also I have made two enhancements of my own (which is the whole point
of doing this).

Firstly, registrations made with a privileged port are flagged as
such, and can only be deregistered with a request from a privileged
port.  That makes it safe for statd/mountd etc to listen on
unprivileged ports.

The only down side I can see to this is if the sysadmin uses:
   pmap_dump
   kill
   restart
   pmap_set
to restart portmap, all the ports will appear to be registered by a
privileged user, so a non-root user who is expecting to be able to
unregister a port will not be able to.

Partly to address this, and partly because I think it is a good idea,
portmap now keeps a copy of it's mapping table in
/var/run/portmap_mapping (even when it chroots elsewhere) and will
reload it on restart.  So pmap_dump/pmap_set is no longer needed.

After any discussion/resolution on the missing Fedora patches, and
maybe some testing/review by others, I would like to make a new
release (maybe called 6.0), announce it on freshmeat, and put a
tar-ball somewhere.  Then nfs-utils-1.1.0 will recommend that
portmap-6.0 be a dependency as mountd no longer listens on a
privileged port.


Comments/review/suggestions welcome.

Thanks for your time.
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
