From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: Hanging exports
Date: 06 May 2003 09:00:25 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1052229626.12560.50.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D2x1-0000Pq-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 06:57:47 -0700
Received: from mosix.vss.fsi.com (mosix [198.51.27.89])
	by esds.vss.fsi.com (8.9.1a/8.9.1) with ESMTP id IAA20205
	for <nfs@lists.sourceforge.net>; Tue, 6 May 2003 08:57:41 -0500 (CDT)
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

I have built an active-active failover solution for NFS with shared
scsi. Everything about the failover seems to work fine, but I run into
some occasional problems on nfs service. I do not believe these to be
related to clustering, as I can experience these problems when there are
no kind of failover scenario occuring..

the problem is this:

exportfs hangs sometimes, both when exporting, and unexporting (exportfs
-u). As a note, I do all of my exportfsing on an export basis. I only
have 1 export listed in /etc/exports, just to ensure that nfs runs at
bootup. Aside from that, each export directory is manually exportfs'd by
a script.

Problem 2 is that the nfs server stops responding to clients. Clients
are solaris 8,6, and irix 6.5. It only seems to be one export that stops
responding. There are a total of 3 exports on the machine. Only the ONE
problem export stops functioning. However, the other exports continue to
work. exportfs -a does nothing.

In both problem scenarios, no log messages (/var/log/messages) appear. 

I'm baffled. Hopefully, someone has an idea.

I am using Redhat 8.0, linux-2.4.18-27.8.0smp kernel (from redhat)

nfs-utils-1.0.1-2

Thanks for your help,

-- 
Matt Schillinger

mschilli@vss.fsi.com





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
