From: Chip Salzenberg <chip@pobox.com>
Subject: Bug#148482: 'nfs-kernel-server reload' immediately stales all nfs handles
Date: Sun, 15 Sep 2002 18:19:31 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020915221931.GE11002@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qhkY-0005iD-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:20:18 -0700
Received: from 0-1pool60-22.nas41.philadelphia1.pa.us.da.qwest.net
	([65.129.60.22] helo=tytlal ident=mail)
	by tandu.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 17qhkX-0005oJ-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:20:17 -0700
Received: from chip by tytlal with local (Exim 3.35 #1 (Debian))
	id 17qhjn-0007T2-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 18:19:31 -0400
To: nfs@lists.sourceforge.net
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

So is 'exportfs -r' *supposed* to stale all NFS handles?  If so, is this
adequately documented?  adTHANKSvance

----- Forwarded message from Herbert Xu <herbert@gondor.apana.org.au> -----

Package: kernel
Version: N/A; reported 2002-05-29
Severity: grave
Justification: causes non-serious data loss

While diagnosing an autofs problem with a particular client, I wanted to reload
changes to the /etc/exports file into the kernel nfs server. I ran:

/etc/init.d/nfs-kernel-server reload

which basically runs the command:

exportfs -r

The man page for this command does not indicate this is a destructive action
and I know I have run this same command on previous versions of the kernel with
no problems.

The result this time was that every client with automounted home directories
immediately got stale file handles which caused them to lose access to their
running apps. We had to go to each client to manually restart autofs on each
client to restore the nfs file handles. Unfortunately, many people lost the
files they were working on.

----- End forwarded message -----

-- 
Chip Salzenberg         - a.k.a.  -        <chip@pobox.com>
         "It furthers one to have somewhere to go."


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
