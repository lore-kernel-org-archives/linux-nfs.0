From: Chip Salzenberg <chip@pobox.com>
Subject: User report: Asymmetric mount failures
Date: Sun, 15 Sep 2002 18:03:21 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020915220321.GC11002@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qhUv-0001Gh-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:04:09 -0700
Received: from 0-1pool60-22.nas41.philadelphia1.pa.us.da.qwest.net
	([65.129.60.22] helo=tytlal ident=mail)
	by tandu.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 17qhUt-0005l3-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:04:08 -0700
Received: from chip by tytlal with local (Exim 3.35 #1 (Debian))
	id 17qhU9-0007PS-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 18:03:21 -0400
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

I would appreciate some help diagnosing this Debian NFS bug report.
If they're using up-to-date Debian unstable as they say, they'll have
been using nfs-utils 1.0 on both machines.

----- Forwarded message from Nick Bailey <n.j.bailey@elec.gla.ac.uk> -----

Subject: Bug#81428: Possibly related mound problem?
From: Nick Bailey <n.j.bailey@elec.gla.ac.uk>
To: 81428@bugs.debian.org
Date: Tue, 06 Aug 2002 18:34:24 +0100

Hi!

I've been having serious difficulty using NFS-kernel-server too, and now 
have the situation where with identical hosts.{deny,allow} and exports, 
machine A can mount /etc from machine B, but not the other way around 
(I'm just using /etc for testing, of course)

So,

root@strauss:/etc# mount -t nfs cmtdb121:/etc /tmp/qqq

On cmtdb121, syslog shows:
Aug  6 18:26:54 cmtdb121 rpc.mountd: authenticated mount request from 
strauss:955 for /etc (/etc)

but...

cmtdb121:/etc# mount -t nfs strauss:/etc /tmp/qqq
mount: strauss:/etc failed, reason given by server: Permission denied

and strauss shows in its syslog:

Aug  6 18:27:25 strauss rpc.mountd: refused mount request from cmtdb121 
for /etc (/): no export entry

I note /etc is somehow referred to / on strauss (no idea why, but this 
would seem to be the cause of the problem), whereas it's correctly 
resolved as /etc on cmtdb121

cmtdb121 is a powerpc, Linux cmtdb121 2.4.18-powerpc #1 Thu Mar 14 
16:55:14 EST 2002 ppc unknown unknown GNU/Linux
Strauss is a dual AMD box with 2 NICs (one unconfigured): Linux strauss 
2.4.18-686-smp #2 SMP Wed Mar 20 20:24:14 EST 2002 i686 unknown unknown 
GNU/Linux

Both of bang-up-to-date Sid installs. the portmapper, nfs-common and 
nfs-kernel-servers have all been stopped and started in the appropriate 
order several times.

Two sysadmins and I have spent almost a whole day on this: I don't think 
it's obvious (although I'm pretty thick at reporting bugs sometimes and 
have dropped a few bricks, at least the sysadmins agree with me this time :)

If there are any other test I could make, please don't hesitate to ask.

Nick/

-- 
Dr Nick Bailey                              n.j.bailey@elec.gla.ac.uk
Centre for Music Technology                 http://cmt.gla.ac.uk/
Dept of Electronics and Electrical Eng      http://www.elec.gla.ac.uk/
The University of Glasgow                   http://www.gla.ac.uk

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
