From: Olaf Kirch <okir@suse.de>
Subject: Re: nfsserver (Suse Linux 9.2) has problems with unix-clients
Date: Wed, 27 Apr 2005 08:52:25 +0200
Message-ID: <20050427065225.GB4232@suse.de>
References: <200504201006.07814.bitz@human-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQgPu-0002kF-Km
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 23:53:02 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DQgPP-0008RT-J5
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 23:53:02 -0700
To: Annette Bitz <bitz@human-solutions.com>
In-Reply-To: <200504201006.07814.bitz@human-solutions.com>
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

On Wed, Apr 20, 2005 at 10:06:07AM +0200, Annette Bitz wrote:
> - nfs-server-2.2beta51-208

As already pointed out, please do not use unfsd anymore.  It's included in
the distribution for some very special use scenarios, but the default
should be the kernel nfsd.

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
