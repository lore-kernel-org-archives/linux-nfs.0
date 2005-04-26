From: Christian Leber <christian@leber.de>
Subject: Re: nfsserver (Suse Linux 9.2) has problems with unix-clients
Date: Tue, 26 Apr 2005 21:01:30 +0200
Message-ID: <20050426190130.GA12057@core.home>
References: <200504201006.07814.bitz@human-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQVJN-0004zi-Sn
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 12:01:33 -0700
Received: from mail4.worldserver.net ([217.13.200.24])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DQVJM-0002xA-0s
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 12:01:33 -0700
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

This is the userspace NFS server.
Please retry with the kernel nfsd.
(no idea, perhaps it's enough to remove the package)

Important HINT for all users of SuSE 9.2:
when you are replacing this old kernel with something recent vanilla you have to
get and start a rpc.lockd, because the SuSE kernel has some funky NFS
patches and with them a kernelspace lockd.


Christian Leber

-- 
http://www.nosoftwarepatents.com



-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
