From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Sun's privileged port settings vs NFS
Date: 24 Jan 2003 10:04:35 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <p5iswey4fw.fsf@lemming.engeast.baynetworks.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from zrtps06s.nortelnetworks.com ([47.140.48.50])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18c5Nu-00083P-00
	for <nfs@lists.sourceforge.net>; Fri, 24 Jan 2003 07:04:46 -0800
Received: from zrtps0m6.us.nortel.com (zrtps0m6.us.nortel.com [47.140.192.58])
	by zrtps06s.nortelnetworks.com (Switch-2.2.0/Switch-2.2.0) with ESMTP id h0OF4cw20538
	for <nfs@lists.sourceforge.net>; Fri, 24 Jan 2003 10:04:38 -0500 (EST)
Received: from lemming.engeast.baynetworks.com (mail@lemming.engeast.baynetworks.com [47.17.140.90])
	by zrtps0m6.us.nortel.com (Switch-2.2.0/Switch-2.2.0) with ESMTP id h0OF4ad20343
	for <nfs@lists.sourceforge.net>; Fri, 24 Jan 2003 10:04:36 -0500 (EST)
Received: from psmith by lemming.engeast.baynetworks.com with local (Exim 3.36 #1 (Debian))
	id 18c5Nj-0002j1-00
	for <nfs@lists.sourceforge.net>; Fri, 24 Jan 2003 10:04:35 -0500
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

We just installed a new set of Solaris servers, and according to
corporate security standards (don't ask me) they have the
nfssrv:nfs_portmon value set to 1, which requires privileged ports.

We are running the Linux kernel from Red Hat 7.2 (2.4.9-34) on our
clients, using am-utils to mount filesystems from these servers.

This all worked great with the old servers (without nfs_portmon set),
and I can automount the filesystems from the new servers _initially_
just fine (I'm using /net/host/...).  However, after the initial timeout
(or sometimes a few timeouts) I start getting these errors on the
client (for any access, not just df, of course):

  $ df /net/zbl6s051/export/.
  df: `/net/zbl6s051/export/.': Permission denied

Apparently caused by these messages on the server (cause/effect is a
little hard to determine positively):

  Jan 24 06:25:35 zbl6s051 nfssrv: [ID 713913 kern.notice] NOTICE: nfs_server: client lemming (47.17.140.90) sent NFS request from unprivileged port

After I get this the only way to recover is unmount the filesystem and
remount it, which is obviously not acceptable.

Some people on the am-utils list seem to think this is more likely
related to NFS than to am-utils, so I'm wondering if anyone here is
familiar with this issue?

The mount parameters am-utils uses when mounting are (from /proc/mounts):

  zbl6s051:/export /amd/net/zbl6s051/export nfs rw,nosuid,v3,rsize=8192,wsize=8192,soft,intr,tcp,lock,addr=zbl6s051 0 0

Also, I have a user running Red Hat 8.0 (Linux 2.4.18-14) and (although
I haven't rigorously verified this yet) although they're running the
same version of am-utils they don't appear to be having this problem.
Maybe there was an NFS fix between 2.4.9 and 2.4.18 that relates to
this?  Or a flag or parameter that can be set?


Thanks for any/all insight you can provide: we're working on rolling out
a new initiative for Linux on the desktop and getting this working is
crucial to its success...

-- 
-------------------------------------------------------------------------------
 Paul D. Smith <psmith@nortelnetworks.com>   HASMAT--HA Software Mthds & Tools
 "Please remain calm...I may be mad, but I am a professional." --Mad Scientist
-------------------------------------------------------------------------------
   These are my opinions---Nortel Networks takes no responsibility for them.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
