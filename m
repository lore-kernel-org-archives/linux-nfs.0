From: ms419@freezone.co.uk
Subject: F_SETLK failed, file already locked
Date: Tue, 21 Sep 2004 18:08:17 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E2C26788-0C33-11D9-AB4A-000A95C71776@freezone.co.uk>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C9vcJ-0004zN-6V
	for nfs@lists.sourceforge.net; Tue, 21 Sep 2004 18:08:19 -0700
Received: from defout.telus.net ([199.185.220.240] helo=priv-edtnes85.telusplanet.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1C9vcH-000074-Hl
	for nfs@lists.sourceforge.net; Tue, 21 Sep 2004 18:08:19 -0700
Received: from tor.lat ([209.121.36.24]) by priv-edtnes85.telusplanet.net
          (InterMail vM.6.01.03.02 201-2131-111-104-20040324) with ESMTP
          id <20040922010810.ZLCI10674.priv-edtnes85.telusplanet.net@tor.lat>
          for <nfs@lists.sourceforge.net>; Tue, 21 Sep 2004 19:08:10 -0600
Received: from [192.168.179.43] (fis.lat [192.168.179.43])
	by tor.lat (Postfix) with ESMTP id 22299149FD
	for <nfs@lists.sourceforge.net>; Tue, 21 Sep 2004 18:08:06 -0700 (PDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I'm running user mode linux using a root image stored on an NFS mount. 
I frequently (though thus far unpredictably) encounter the following 
error starting UML:

F_SETLK failed, file already locked by pid 25176

http://www.sfu.ca/~jdbates/nfs/screenlog

Where "pid 25176" changes, but is never the pid of a running process: 
I've tried "ls /proc/25176", no such process exists. So far, the only 
solution I've found is restarting the NFS server. This corrects the 
problem every time.

I don't know whether the problem is with the NFS server, NFS client, or 
user mode linux. Can anyone advise?

The NFS server is running Debian unstable, nfs-kernel-server 1.0.6-3, & 
a custom 2.4.27 kernel.

The NFS client is running Debian unstable, nfs-common 1.0.6-3, & a 
custom 2.6.7 kernel. They're connected by a crossover cable @ 10/100.

Thank you very much for any help!

Jack



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
