From: mb/nfs@dcs.qmul.ac.uk
Subject: Re: trouble with file locking
Date: Thu, 27 Nov 2003 15:27:51 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0311271526510.19011@lucy.dcs.qmul.ac.uk>
References: <20031112105043.020c1548.erik@thiele-hydraulik.de>
 <Pine.LNX.4.58.0311191259400.846@lewis.et.byu.edu> <shsd6bohzxw.fsf@charged.uio.no>
 <20031120070531.7886de98.erik@thiele-hydraulik.de> <16316.23490.266052.855506@charged.uio.no>
 <Pine.LNX.4.58.0311241416240.7849@lucy.dcs.qmul.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APO40-0005Ce-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 07:28:16 -0800
Received: from vicar.dcs.qmul.ac.uk ([138.37.88.163] helo=mail.dcs.qmul.ac.uk)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1APO40-0003d3-Ia
	for nfs@lists.sourceforge.net; Thu, 27 Nov 2003 07:28:16 -0800
Received: from lucy.dcs.qmul.ac.uk ([138.37.88.16])
	by mail.dcs.qmul.ac.uk with asmtp (TLSv1:DHE-RSA-AES256-SHA:256)
	(Exim 4.24)
	id 1APO3b-0003mL-V5
	for nfs@lists.sourceforge.net; Thu, 27 Nov 2003 15:27:51 +0000
In-Reply-To: <Pine.LNX.4.58.0311241416240.7849@lucy.dcs.qmul.ac.uk>
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

On Nov 24 mb/nfs@dcs.qmul.ac.uk wrote:

>I tried writing a trivial program to test lockf() and it returns ENOLCK 
>over NFS, but succeeds locally. The client kernel offers some grumbles:
>
>RPC: Can't bind to reserved port (13).
>RPC: can't bind to reserved port.
>nsm_mon_unmon: rpc failed, status=-5

solved over on LKML; solution: "modprobe capability"


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
