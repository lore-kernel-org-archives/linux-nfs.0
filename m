From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: file locking error (37!) NFS problem
Date: 17 Sep 2003 11:36:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsllsnctq6.fsf@charged.uio.no>
References: <3F6878DA.7070101@biochem.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zeMC-00008N-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 08:36:40 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zeMB-000325-SA
	for nfs@lists.sourceforge.net; Wed, 17 Sep 2003 08:36:40 -0700
To: Bernhard Busch <bbusch@biochem.mpg.de>
In-Reply-To: <3F6878DA.7070101@biochem.mpg.de>
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

>>>>> " " == Bernhard Busch <bbusch@biochem.mpg.de> writes:

     > Hello NFS Experts I upgraded a NFS Server from Suse 8.0 to Suse
     > 8.1.

     > If i use the EMAN program (Electron Image Processing Program,
     > cluster version) from

     > a client with Suse8.0 (the data files are on the fileserver) ,
     > i get the error message



     > file locking error (37!) NFS problem

*IF* the '37' is actually the error code returned by the kernel (in
which case it seems stupid that they don't use 'perror()' to report it
in standard format, but whatever...), then that would just be -ENOLCK
(i.e. the lock failed).

Check that your new server is not firewalling the port that is being
used by lockd. ('rpcinfo -p' will tell you which port that is).

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
