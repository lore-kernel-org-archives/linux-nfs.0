From: Duane Ellis <duane_ellis@franklin.com>
Subject: FAQ submission with answer
Date: Sat, 26 Oct 2002 13:22:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210261722.g9QHMnF12943@europa.franklin.com>
Reply-To: duane_ellis@franklin.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from newfrnk82.franklin.com ([63.88.59.82] helo=earth-out.franklin.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 185Udo-0008E6-00
	for <nfs@lists.sourceforge.net>; Sat, 26 Oct 2002 10:22:28 -0700
To: trmcneal@attbi.com, nfs@lists.sourceforge.net
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


I have a "FAQ" question and at least
an Answer or work around for the problem.

I hope this helps others on this list
(I am not on the nfs list)

I am an administer a fairly large 
Unix network ( +50 SunOS boxes, and +20 linux boxes)
and have hit this problem a few times when
configuring a new linux machine.

I am trying to export "/" (root) file system
from one linux box to all others via the
the directory construct:

  # cd /net/HOSTNAME/filesystem 

When I run the exportfs command, I got a cryptic
message that did not help what so ever.

# exportfs -ra
europa:/: Invalid argument

Manytimes this is mis-diagnosted as a condition
where you are exporting a sub-directory of an
already exported file system - That's not my
problem.

Specifically my problem is this:
  The file /var/lib/nfs/rmtab had a stale
  entry in it.

Specifically to fix my problem I had to do this:
  # [stop nfs]
  # cd /var/lib/nfs
  # rm -f etab mtab rmtab
  # touch rmtab	
    [otherwise exportfs complains]
  # [start nfs]

A better answer would be to explain or fix why
the file /var/lib/nfs/rmtab had the stale entry
or to fix what ever updates the file.

Perhaps this is a latent bug that is inside of NFS or
one of the other utlities, or maybe these files
should be removed during a reboot as part of some
type of 'house-cleaning' operation.

It appears that a fix was offered to this problem
in this posting, but it has ether not picked up
or not trickled through to all the various distros.

http://sourceforge.net/mailarchive/message.php?msg_id=553411
look for:
        >> # First we should cleanup and then prepare our exports.
 	> /var/lib/nfs/etab	#
 	> /var/lib/nfs/xtab	# contains list of exportable filesystems
 	>> /var/lib/nfs/rmtab	# list of used exported filesystems

Thanks.

-Duane Ellis

Others have seen this problem too:

http://sourceforge.net/mailarchive/message.php?msg_id=1228515

http://sourceforge.net/mailarchive/message.php?msg_id=550491

It appears that a fix was offered to this problem
in this posting:
http://sourceforge.net/mailarchive/message.php?msg_id=553411
look for:
        >> # First we should cleanup and then prepare our exports.
 	> /var/lib/nfs/etab	#
 	> /var/lib/nfs/xtab	# contains list of exportable filesystems
 	>> /var/lib/nfs/rmtab	# list of used exported filesystems
 
http://www.geocrawler.com/archives/3/789/2001/8/50/6372419/

http://www.cs.helsinki.fi/linux/linux-kernel/2002-01/0811.html

https://listman.redhat.com/pipermail/wolverine-list/2001-March/001096.html

http://plug.skylab.org/199906/msg00469.html

http://www.van-dijk.net/linuxkernel/200202/0583.html.gz


-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
