From: =?iso-8859-1?q?Wiesner=20Thomas?= <w15mail@yahoo.de>
Subject: NFS: Problem on changing runlevels
Date: Mon, 16 Jun 2003 17:55:29 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030616155529.78882.qmail@web21203.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web21203.mail.yahoo.com ([216.136.130.22])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19RwKP-0005el-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Jun 2003 08:55:29 -0700
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

Hello!

I have installed Debian Linux 3.0r1 and a
home-compiled 2.4.18 kernel (no additional patches)
with NFS-kernel-server (compiled in).
Everything seems to work, but when I change the
runlevel to 1 and to 2 after doing something or simply
typing CNTRL-D the system hangs at this point:

  Starting NFS kernel daemon: nfsd

I can recover by pressing CNTRL-ALT-DEL and it
shuts down and reboots normally.
When I look into /var/log/daemon.log, I find these
lines (tail part):

Jun 15 16:38:38 fserverII init: Switching to runlevel:
1
Jun 15 16:38:45 fserverII rpc.statd[149]: Caught
signal 15, un-registering and exiting.
Jun 15 16:39:23 fserverII rpc.statd[250]: Version 1.0
Starting
Jun 15 16:39:23 fserverII rpc.statd[251]: unable to
register (statd, 1, udp). 
Jun 15 16:39:59 fserverII init: Switching to runlevel:
6
Jun 15 16:40:54 fserverII rpc.statd[148]: Version 1.0
Starting

So it isn´t a serious problem, but sometimes I need
the single user mode and it´s nasty to reboot after
using it.

BTW: I have the looback device configured (as
done by the debian-setup). I mentioned this, because
somebody else seemed to have troubles with NFS without
it.

Does anyone know went wrong (and how I can correct
it)?
Tanks.

__________________________________________________________________

Gesendet von Yahoo! Mail - http://mail.yahoo.de
Logos und Klingeltöne fürs Handy bei http://sms.yahoo.de


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
