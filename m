From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS Performance Between SGI Servers and Linux Clients
Date: 22 May 2003 23:12:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsllwylm7a.fsf@charged.uio.no>
References: <008601c3207f$b8bfd160$0b00430a@granger>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IxN4-00044M-00
	for <nfs@lists.sourceforge.net>; Thu, 22 May 2003 14:13:06 -0700
To: "Iain Irwin-Powell" <iain@cinesite.co.uk>
In-Reply-To: <008601c3207f$b8bfd160$0b00430a@granger>
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

>>>>> " " == Iain Irwin-Powell <iain@cinesite.co.uk> writes:

     > Looking a bit deeper in a packet trace when the grep is
     > running, Linux seems to issue 16 read requests (16KB) at a time
     > whilst an SGI will only issue between 2 and 4. May or may not
     > be relevant.

... and this is a problem because .... ???

The Linux client tries to read ahead as much as it can and as quickly
as it can. Why should it doing anything else?

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
