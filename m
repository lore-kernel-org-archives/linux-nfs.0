From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs/mmap/rename file corruption
Date: 27 Aug 2003 21:37:38 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1xv6ftp9.fsf@charged.uio.no>
References: <20030828110309.0e0eff6f.mbp@sourcefrog.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sBjd-0000XW-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 18:38:01 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19sBjR-0002dl-8a
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 18:37:49 -0700
To: Martin Pool <mbp@sourcefrog.net>
In-Reply-To: <20030828110309.0e0eff6f.mbp@sourcefrog.net>
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

>>>>> " " == Martin Pool <mbp@sourcefrog.net> writes:

     > - ccache runs distcc with output to a temporary file
     >  - distcc opens, mmaps, writes to, munmaps, and closes the temporary
     >    file
     > - distcc exits
     >  - ccache renames the temporary file to its proper location in the
     >    ccache
     > - ccache opens the file read only, and reads from it

Is this a rename from one directory to the other? If so, are you using
the 'no_subtree_check' option on the server? Without the latter option
enabled, I would indeed expect the behaviour that you describe.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
