From: Joseph Tam <tam@math.ubc.ca>
Subject: LinuxFC6 NFS client problem: cannot distinguish between
	sub-volumes
Date: Thu, 22 Feb 2007 18:35:06 -0800 (PST)
Message-ID: <Pine.GSO.4.64.0702221830010.4782@mnc.zngu.hop.pn>
References: <mailman.653.1172186165.14402.nfs@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HKQH3-0002Nb-Dc
	for nfs@lists.sourceforge.net; Thu, 22 Feb 2007 18:35:05 -0800
Received: from viol.math.ubc.ca ([137.82.36.61])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HKQH5-00075O-8H
	for nfs@lists.sourceforge.net; Thu, 22 Feb 2007 18:35:07 -0800
Received: from zap (zap.math.ubc.ca [137.82.36.8])
	by viol.math.ubc.ca (8.13.7/8.13.7) with ESMTP id l1N2Z6ft011164
	for <nfs@lists.sourceforge.net>; Thu, 22 Feb 2007 18:35:06 -0800 (PST)
In-Reply-To: <mailman.653.1172186165.14402.nfs@lists.sourceforge.net>
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


I have two problems that seem to stem from the same cause.

The situation is that I have a NetApp filer (but it also exhibits these
problems when using a Solaris NFS server) that has a large volume, with individual
sub-volumes or qtrees (should the term here be "logical volumes") which
behave like individual filesystems (i.e. they can be mounted individually,
have theor own quotas, etc.).

The logical volumes are mounted on the LinuxFC6 client (kernel 2.6.19-1.2911.fc6)
via automount (NFSv3).

However, the Linux FC6 client NFS cannot distinguish between these automounted
directories (the FSID in /proc/fs/nfsfs/volumes seem to be the same) with the
following consequences:

 	- quota reporting is curtailed.  It reports on maybe the first
 	mounted filesystem, and ignored the rest since it thinks it
 	it has the same quotas.

 	- the order of mounting becomes important: the first mounted
 	filesystem has its mount options override the mount options for
 	later mounts.

The first problem has been partially fixed: the author of quota-tools (Jan Kara)
has quite kindly wrote an -A option to his quota program that will work
around this (I think it uses a fallback method of doing a stat() call).

However, I cannot seem to cope with the second.  An example of this
would be having read-only mounts (like /usr/local) and read/write home
directories (/nfs/user1) both being mounted.

If this happens,

 	mount -o rw nfs-server:/vol/home/user1 /nfs/user1
 	mount -o ro nfs-server:/vol/local/linux /nfs/local

then /nfs/local is actually mounted r/w (according to /proc/mounts) but this
is workable since the NFS server will enforce the r/o policy.  If the order
is reversed, this is disastrous as the user will end up with a non-writable
home directory.

Has any of the recent patches addressed this problem (I see hints like

 	http://marc.theaimsgroup.com/?l=linux-nfs&m=117041136218203&w=2
 	http://marc.theaimsgroup.com/?l=linux-nfs&m=117126072001306&w=2

), but I'm not technically savvy enough about NFS to figure out whether these
patches help.  I've also tried putting fsid=xxx in the automount maps, but
this doesn't seem to get passed to the client (fsid= is only a /etc/exports
option, right?).  There doesn't seem anything on the server side that can
help me either.

So I'm stuck.  Help, please?

Joseph Tam <tam@math.ubc.ca>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
