From: Frans Pop <aragorn@tiscali.nl>
Subject: Re: Debian bug #165744 - 'Received erroneous SM_UNMON request'
Date: Sat, 13 Sep 2003 22:02:44 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309132202.47195.aragorn@tiscali.nl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19yGbb-0003nd-00
	for <nfs@lists.sourceforge.net>; Sat, 13 Sep 2003 13:02:51 -0700
Received: from matilda.tiscali.nl ([195.241.51.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19yGbb-0008Su-1d
	for nfs@lists.sourceforge.net; Sat, 13 Sep 2003 13:02:51 -0700
To: Chip Salzenberg <chip@debian.org>,
	Neil Brown <neilb@cse.unsw.edu.au>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello Chip, Neil,

I think I may have found the source of this bug.
In Debian, rpc.statd is compiled with --enable-secure-statd; when I recompi=
le=20
with this option diabled, the error messages disapear!

I tried this after I took a look at the source for rpc.statd. I noticed tha=
t=20
in monitor.c there is the statement
   my_name =3D "127.0.0.1"
when servicing SM_MON requests with secure-statd enabled.
I think in my setup this causes the lookups in the run-time list (which use=
=20
my_name) to fail when servicing SM_UNMON requests if in my situation my_nam=
e=20
is equal to the real adresses of my boxes, causing the 'Received erroneous=
=20
SM_UNMON request' errors.

I think this would also explain the 'notify_host: failed to notify 127.0.0.=
1'=20
errors. This second error occurs when I reboot the server while a=20
NFS-connection was up: after restarting the server tries to notify the clie=
nt=20
it is back up, but can't because the client is not at localhost but at=20
10.19.66.21 and there is no NFS-client running on the server itself.

I think the reason the error appears in my setup could be because I have NF=
S=20
kernel-support compiled in both server and clients. In Debian, this means=20
rpc.lockd is not run from the init scripts. (In /etc/init.d/nfs-common 'gre=
p=20
=2D -q lockdctl /proc/ksyms' returns 1, so NEED_LOCKD is set to 'no'.)

I have (from ps alx):
  F   UID   PID  ... WCHAN  STAT ... COMMAND
140     1   129      poll   S        /sbin/portmap
040     0   135      rpciod SW       [rpciod]
040     0   136      svc_re SW       [lockd]
140     0   214      select S        /sbin/rpc.statd

I can easily reproduce the errors by restoring the original binary of=20
rpc.statd. Also, the error occurs on all - well both - my nfs-clients. The=
=20
error occurs very frequently when I am running with the original binaries.

Hope this information helps. I am willing to help any way I can to solve th=
is=20
bug.

Regards,

=46rans Pop

P.S. I already send a similar message to 165744@bugs.debian.org (CC Neil) o=
n=20
August 29, but as there was no reply to date I am trying again. I would=20
appreciate a reply.
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE/Y3fkgm/Kwh6ICoQRApboAJ4gqgBY/KRL3WZg6QNu+jnni/5xwQCfTc6z
6/R4stFNt+a8EnlXjOp3NI8=3D
=3D/CN2
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
