From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: how to enable locking in NFS?
Date: 18 May 2003 17:43:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shssmrcjm61.fsf@charged.uio.no>
References: <20030517061202.38292.qmail@web8201.mail.in.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19HQJd-0000IX-00
	for <nfs@lists.sourceforge.net>; Sun, 18 May 2003 08:43:13 -0700
To: Hank Shah <hankshah@yahoo.co.in>
In-Reply-To: <20030517061202.38292.qmail@web8201.mail.in.yahoo.com>
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

>>>>> " " == Hank Shah <hankshah@yahoo.co.in> writes:


     > Is fcntl locking used for the same?  If yes,how do we enable
     > it?  Do we have to include a seperate code for it in nfsd?  We
     > are using Redhat Linux 7.2 , kernel 2.4.7-10, NFSv3

There is no support for mandatory locking under NFSv2 or NFSv3.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: If flattening out C++ or Java
code to make your application fit in a relational database is painful, 
don't do it! Check out ObjectStore. Now part of Progress Software.
http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
