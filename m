From: Olaf Kirch <okir@suse.de>
Subject: Re: nfsserver (Suse Linux 9.2) has problems with unix-clients
Date: Wed, 27 Apr 2005 08:50:10 +0200
Message-ID: <20050427065009.GA4232@suse.de>
References: <200504201006.07814.bitz@human-solutions.com> <20050426190130.GA12057@core.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Annette Bitz <bitz@human-solutions.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQgNW-0002eU-9Z
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 23:50:34 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DQgNT-0000iC-Nu
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 23:50:34 -0700
To: Christian Leber <christian@leber.de>
In-Reply-To: <20050426190130.GA12057@core.home>
Sender: nfs-admin@lists.sourceforge.net
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

On Tue, Apr 26, 2005 at 09:01:30PM +0200, Christian Leber wrote:
> Important HINT for all users of SuSE 9.2:
> when you are replacing this old kernel with something recent vanilla you have to
> get and start a rpc.lockd, because the SuSE kernel has some funky NFS
> patches and with them a kernelspace lockd.

Lockd has been a kernel thread all along from day one. What you're
referring to is the kernel space statd.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
