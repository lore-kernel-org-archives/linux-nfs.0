From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: 2.6.27.19 lockd waits too long
Date: Tue, 3 Mar 2009 10:45:14 +0100
Message-ID: <20090303094514.GT89843@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:61390 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753493AbZCCJpR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2009 04:45:17 -0500
Received: from kazi.fit.vutbr.cz (localhost [127.0.0.1])
	by kazi.fit.vutbr.cz (envelope-from kasparek@fit.vutbr.cz) (8.14.3/8.14.3) with ESMTP id n239jFNZ001861
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 3 Mar 2009 10:45:15 +0100 (CET)
Received: (from kasparek@localhost)
	by kazi.fit.vutbr.cz (8.14.3/8.13.1/Submit) id n239jE3d001860
	for linux-nfs@vger.kernel.org; Tue, 3 Mar 2009 10:45:14 +0100 (CET)
	(envelope-from kasparek@fit.vutbr.cz)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

after solving previous problem with buggy FreeBSD server, I hit another
one.

I tryied 2.6.27.19+linger patch on servers and they work well, so I moved
to clients. On my desktop machine (pckasparek) with the same system (CentOS
5.2 + 2.6.27.19) the system freezes when running acroread or openoffice. I
tracked it down to NFS locking of files in $HOME which is NFS3 
(rw,nodev,intr,hard,rsize=8192,wsize=8192,bg,nfsvers=3,tcp) mounted from
server (kazi).

With real application the system is freezed for minutes up to hours (one
all the night) and gets running when i kill -9 acroread/OOo. I wrote a
simple test app that basicly does fcntl64(F_GETLK), F_SETLK, F_UNLCK and
repeats that several times. With this app it wait only before the first
fcntl call and only for much shorter time (10-30sec). I was able to get
some hopefully interesting info (included in attachments).

- netstat on client and server before and after nfs-lock was run
- wireshark dump of all packets
- dmesg from client with sysrq/W - blocked tasks (and lockd: server kazi
  not responding, still trying messages)

Seems like there is still some trouble in creating new/properly clearing
old connections between the client and server.

With previous kernel (2.6.24.7) the client run just fine.

Any suggestions what to try? 

Thanks in advance

(was not able to send this mail with attachments, trying this way)
http://merlin.fit.vutbr.cz/tmp/nfs/netstat-end.txt
http://merlin.fit.vutbr.cz/tmp/nfs/netstat-start.txt
http://merlin.fit.vutbr.cz/tmp/nfs/pckaspare-kazi.dump
http://merlin.fit.vutbr.cz/tmp/nfs/pckasparek-dmesg.txt

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

