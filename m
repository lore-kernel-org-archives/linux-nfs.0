From: mb/nfs@dcs.qmul.ac.uk
Subject: Re: trouble with file locking
Date: Mon, 24 Nov 2003 14:24:28 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0311241416240.7849@lucy.dcs.qmul.ac.uk>
References: <20031112105043.020c1548.erik@thiele-hydraulik.de>
 <Pine.LNX.4.58.0311191259400.846@lewis.et.byu.edu> <shsd6bohzxw.fsf@charged.uio.no>
 <20031120070531.7886de98.erik@thiele-hydraulik.de> <16316.23490.266052.855506@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AOHdl-00032D-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Nov 2003 06:24:37 -0800
Received: from vicar.dcs.qmul.ac.uk ([138.37.88.163] helo=mail.dcs.qmul.ac.uk)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1AOHdk-0004bU-OD
	for nfs@lists.sourceforge.net; Mon, 24 Nov 2003 06:24:36 -0800
Received: from lucy.dcs.qmul.ac.uk ([138.37.88.16])
	by mail.dcs.qmul.ac.uk with asmtp (TLSv1:DHE-RSA-AES256-SHA:256)
	(Exim 4.24)
	id 1AOHdd-0000xS-FT
	for nfs@lists.sourceforge.net; Mon, 24 Nov 2003 14:24:29 +0000
To: nfs@lists.sourceforge.net
In-Reply-To: <16316.23490.266052.855506@charged.uio.no>
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

On Nov 20 Trond Myklebust wrote:

>Then you have been using POSIX locks (i.e. fcntl()/lockf()). They
>should work fine.

Possibly unrelated [hence CC trimmed]:

I can't get Debian testing to log in to GNOME when home directories are
mounted over NFS (Linux 2.6-mm client -> Linux 2.4-ac server). It claims 
not to be able to lock a file..

I tried writing a trivial program to test lockf() and it returns ENOLCK 
over NFS, but succeeds locally. The client kernel offers some grumbles:

RPC: Can't bind to reserved port (13).
RPC: can't bind to reserved port.
nsm_mon_unmon: rpc failed, status=-5
lockd: cannot monitor a.b.c.d
lockd: failed to monitor a.b.c.d

[where a.b.c.d is our NFS server]

/sbin/rpc.statd is running on both client and server, and with a 2.4 
kernel on the client (as the only change) GNOME logins work just fine.

Any ideas? I'm stumped at this point.

Cheers,

Matt


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
