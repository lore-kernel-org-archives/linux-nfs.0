From: Chip Salzenberg <chip@pobox.com>
Subject: More user reports: '{Random,Consistent} mount refusals'
Date: Sun, 15 Sep 2002 18:09:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020915220953.GD11002@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qhbF-0002EX-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:10:41 -0700
Received: from 0-1pool60-22.nas41.philadelphia1.pa.us.da.qwest.net
	([65.129.60.22] helo=tytlal ident=mail)
	by tandu.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 17qhbC-0005n6-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:10:39 -0700
Received: from chip by tytlal with local (Exim 3.35 #1 (Debian))
	id 17qhaT-0007Pz-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 18:09:53 -0400
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

I really don't know what to make of Debian bugs 81428 and 131811:

  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=81428&repeatmerged=yes
  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=131811&repeatmerged=yes

Here is the most recent message from 81428.  Please help me figure out
what's going on here ... I'm mostly packaging and mostly not coding in
NFS land, and these reports are awfully confusing.

----- Forwarded message from Adam C Powell IV <hazelsct@mit.edu> -----

Subject: Bug#81428: I'm still getting random mount refusals
From: Adam C Powell IV <hazelsct@mit.edu>
Date: Tue, 15 Jan 2002 09:58:39 -0500

Even with 1.0-2 on a 2.4.9 kernel which I rebooted yesterday, I'm still 
getting this problem.  For a while I thought it was just a matter of 
being slow to respond to changes in /etc/exports (like, I make a change, 
but it doesn't take, then suddenly a few days later without restarting 
the server, it magically works and I can mount).  I often try testing 
every day after a change, and it takes somewhere between five and eight 
days for the change to take effect.  This goes both for netgroup, 
wildcard (*.domain.edu) and individual machine type entries in 
/etc/exports, for clients in /etc/hosts.

Last night, the server crashed (no idea why), so I rebooted, and 
remounted one of the dirs on the client machines while the server was 
still fscking it, so the fs was not mounted on the server, and the dir 
was empty.  When the fsck was done and the dir mounted on the server, 
"ls /dir" on the client still showed it empty.  This morning, I tried to 
unmount and remount, but got:

mount: <server>:/dir failed, reason given by server: Permission denied

Here's /var/log/messages on the server for this unmount-mount:

Jan 15 09:35:44 <server> rpc.mountd: authenticated unmount request from 
<client.domain.edu>:702 for /dir (/dir)
Jan 15 09:35:46 <server> rpc.mountd: authenticated mount request from 
<client.domain.edu>:703 for /dir (/dir)
Jan 15 09:35:46 <server> rpc.mountd: getfh failed: Operation not permitted

It's possible that kernels newer than 2.4.9 have fixed this, but 2.4.14 
through 2.4.17 have been misidentifying my disk labels (I'm about to 
file a bug), so I can't test them on that server.

This bug is *so* annoying, I can't tell you, and has been since about 
the time this bug was submitted.  Please don't close this until you know 
for certain it is fixed - until the submitter or (if you can't reach 
him/her) I confirms that it's fixed.  I really hope it gets fixed before 
the woody release!

Zeen,
-- 

-Adam P.

GPG fingerprint: D54D 1AEE B11C CE9B A02B  C5DD 526F 01E8 564E E4B6

Welcome to the best software in the world today cafe! 
<http://lyre.mit.edu/%7Epowell/The_Best_Stuff_In_The_World_Today_Cafe.ogg>

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
