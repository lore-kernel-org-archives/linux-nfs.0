From: "Steve M. Robbins" <steven.robbins@videotron.ca>
Subject: erroneous SM_UNMON request
Date: Tue, 15 Apr 2003 15:41:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030415194154.GB2469@nyongwa.montreal.qc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relais.videotron.ca ([24.201.245.36] helo=VL-MS-MR001.sc1.videotron.ca)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 195WJt-0000Sc-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Apr 2003 12:42:18 -0700
Received: from riemann.nyongwa.montreal.qc.ca ([24.202.211.97])
 by VL-MS-MR001.sc1.videotron.ca
 (iPlanet Messaging Server 5.2 HotFix 1.10 (built Jan 23 2003))
 with ESMTP id <0HDE003DDHEEMO@VL-MS-MR001.sc1.videotron.ca> for
 nfs@lists.sourceforge.net; Tue, 15 Apr 2003 15:42:14 -0400 (EDT)
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

Hello,

I have just installed a new linux disk server, and have been plagued by
syslog messages such as the following

    Apr 15 14:26:07 jeff rpc.statd[17998]: 
    Received erroneous SM_UNMON request from jeff for 132.206.3.109


In my researches to date, the answer that others have received about
this is along the lines of the following.

    Basically it means that your rpc.statd daemon is unaware of a lot
    of its clients. It is probably failing to save their IP-numbers to
    disk. Check therefore that the directories /var/lib/nfs/sm, and
    /var/lib/nfs/sm.bak (or /var/lib/nfs/statd/sm, ... on some
    platforms) are writable by the rpc.statd process.

    http://lists.insecure.org/linux-kernel/2001/Dec/5052.html

In my case, /var/lib/nfs/sm contains empty files named with the IP
of the clients involved.  I presume this means that the statd
process can write there.  The command "ps aux" shows statd running
as root; it doesn't drop privileges, does it?


The files in /var/lib/nfs/sm appear to be correlated with me using the
mail user agent "mutt" on a client machine.  Mutt is reading (and
locking) the mail spool, which is exported over NFS, mounted using
options "hard,intr".  I vaguely recall choosing these options
deliberately, but now I'm wondering whether a hard mount is
inadvisable.


In any case, I'm worried that the erroneous requests are a symptom of
some underlying problem.  I'd be grateful for suggestions on where to
look for further clues.  

The server is running Debian "stable", but with nfs-utils updated to
1.0.3, and with kernel version 2.4.20.  The client systems are Debian
"testing", also with nfs-utils 1.0.3 and kernel versions 2.4.x for x
about 18 or 20.  The mail spool is exported with the "sync" option.

I notice now that the client systems have reciprocal "erroneous
SM_UNMON" messsages in _their_ syslogs.  From my limited understanding
(mainly from http://www.opengroup.org/onlinepubs/009629799/chap9.htm)
I gather this is to be expected.


All advice will be gratefully recieved,
-Steve


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
