From: Jan Rekorajski <baggins@sith.mimuw.edu.pl>
Subject: lockd not responding
Date: Tue, 6 Mar 2007 21:17:54 +0100
Message-ID: <20070306201754.GB20115@sith.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOg6g-0001n6-92
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 12:18:00 -0800
Received: from sith.mimuw.edu.pl ([193.0.96.4] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOg6g-0007Ew-1I
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 12:18:00 -0800
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

Hi,
After applying Trond's patches the oops problem went away but now I'm
back to comatose lockd.

rainbow is a NFS server, sith a random client:

[baggins@sith ~]$ rpcinfo -p rainbow | grep lock
    100021    1   udp  32774  nlockmgr
    100021    3   udp  32774  nlockmgr
    100021    4   udp  32774  nlockmgr
    100021    1   tcp  37150  nlockmgr
    100021    3   tcp  37150  nlockmgr
    100021    4   tcp  37150  nlockmgr

[baggins@sith ~]$ rpcinfo -u rainbow 100021
rpcinfo: RPC: Timed out
program 100021 version 0 is not available

[baggins@sith ~]$ rpcinfo -t rainbow 100021
rpcinfo: RPC: Timed out
program 100021 version 0 is not available

[baggins@sith ~]$ telnet rainbow 37150
Trying 10.1.1.4.37150...
Connected to rainbow.mimuw.edu.pl.
Escape character is '^]'.
^]
telnet>

[root@rainbow ~]# ps aux | grep "\[lockd\]"
root      3786  0.0  0.0      0     0 ?        S    01:55   0:00 [lockd]

So, lockd is up and running, I can connect to it, but it's not responding
to RPC calls, what's interesting that it works just after the reboot and
only after some time it stops.

I also see a lot of these in logs on server
(red13 is another NFS client):

portmap: server red13 not responding, timed out
lockd: server red13 not responding, timed out
lockd: couldn't create RPC handle for red13

Looks to me that lockd loops over some dead client and is so wind up in
doing so that it has no time to answer new calls.

Jan
-- 
Jan Rekorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
