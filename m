From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: cache/mmap()/server coherency problems
Date: 14 Jan 2003 16:51:53 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsfzrv20h2.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0301132011250.12181-100000@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YTMC-0000c7-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 07:52:05 -0800
To: Chris Caputo <ccaputo@alt.net>
In-Reply-To: <Pine.LNX.4.44.0301132011250.12181-100000@nacho.alt.net>
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

>>>>> " " == Chris Caputo <ccaputo@alt.net> writes:

     > On 2.4.18 and 2.4.20 I am seeing the following problem:
     >  1) client A process C opens and mmaps (PROT_READ, MAP_SHARED) a file on
     >     an NFS server.  It keeps it mapped for the duration of the
     >     following steps.

     >  2) client B process D opens, adds data to the end of the same file, and 
     >     then closes it.

     > 3) client B process E runs md5sum on the file.

     >  4) client A process F runs md5sum on the file too.  But the result is 
     >     different than the result of the md5sum in step 3.

     > Under kernel 2.2.21 this problem did not happen.

Of course it did! NFS cache coherency is *NEVER* guaranteed if 2
clients are accessing the same file simultaneously particularly so for
mmap(). That goes for all NFS implementations on all OSes...

Using POSIX file locking can help you for ordinary file acces, but for
mmap(), even file locking has issues under 2.4.x.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
