From: Ryan Sweet <rsweet@atos-group.nl>
Subject: mount:not a directory
Date: Fri, 12 Apr 2002 13:50:03 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0204121218370.29572-100000@core-0>
Reply-To: Ryan Sweet <rsweet@atos-group.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [62.58.73.254] (helo=ats-core-0.atos-group.nl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vzhd-0007SX-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Apr 2002 04:58:53 -0700
To: <autofs@linux.kernel.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


I have a network running mostly Linux 2.2.19 with redhat 7.0, with some
systems upgraded to 2.4.  We're using autofs-3.1.6.  We use nis with the
following auto.master:

--
/import/direct yp:auto.direct
/home yp:auto.home
/var/spool/mail yp:auto.mail
--

and an auto.mail like so:

--
username nfs-server:/export/mail/username
--

Which works fine with all of our RedHat 7.0 and earlier machines, as well
as with our various other *NIX.  Any time a user references their mail
file (/var/spool/mail/username) it is automounted under /var/spool/mail.
On any new RedHat 7.2 system however, which seem to come with
autofs-3.1.7, it fails like so:

Apr 12 13:18:59 file2 automount[30855]: starting automounter version
3.1.7, path = /var/spool/mail, maptype = yp, mapname = auto.mail
Apr 12 13:18:59 file2 autofs: automount startup succeeded
Apr 12 13:19:00 file2 automount[30855]: using kernel protocol version 3
Apr 12 13:20:46 file2 automount[30855]: attempting to mount entry
/var/spool/mail/rsweet
Apr 12 13:20:46 file2 kernel: nfs warning: mount version older than
kernel
Apr 12 13:20:47 file2 automount[30873]: >> mount: Not a directory
Apr 12 13:20:47 file2 automount[30873]: mount(nfs): nfs: mount failure
mail-1:/export/mail/rsweet on /var/spool/mail/rsweet

Of course, /export/mail/rsweet and /var/spool/mail/rsweet are not
directories, they are files, but that doesn't help because it works
spectacularly on all the other systems.

RH 7.2+updates gives me nfs-utils 0.3.1x and mount 2.11g.  I've tried
upgrading to the latest mount (2.11q) and nfs-utils (0.3.3) sources and
also downgrading to the RH 7.0 versions (mount 2.10m, nfs-utils 0.2.1),
but always have the same problem.  Note that even with the latest mount
(2.11q) I still get the message that the mount version is older than
kernel (stock redhat 7.2 updates 2.4.9-13).  I also tried downgrading to
autofs 3.1.6, but that didn't help either.

The same accounts, files, servers work fine when the client is not running
rh7.2.

I have strace output if it would help - it basically just shows that the
call to mount:

[pid 30941] mount("mail-1:/export/mail/rsweet", "/var/spool/mail/rsweet",
"nfs", 0xc0ed0000, 0x8058a20) = -1 ENOTDIR (Not a directory)

returns "not a directory"....

Any ideas?

thanks,
-Ryan Sweet

-- 
Ryan Sweet <ryan.sweet@atosorigin.com>
Atos Origin Engineering Services
http://www.aoes.nl




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
