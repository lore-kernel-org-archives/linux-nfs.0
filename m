From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Heavy problems with NFS (2.4.20)
Date: 20 Feb 2003 23:32:58 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65rezip1.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0302201600090.19940-100000@g31.physik.fu-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lzFb-0004yl-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 14:33:07 -0800
To: Tobias Burnus <tobias.burnus@physik.fu-berlin.de>
In-Reply-To: <Pine.LNX.4.44.0302201600090.19940-100000@g31.physik.fu-berlin.de>
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

>>>>> " " == Tobias Burnus <tobias.burnus@physik.fu-berlin.de> writes:

     > Any ideas how we can reduce the inpact?

You might perhaps consider using an automounter. Either amd or autofs
should do the job.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
