From: Kumaran Rajaram <kums@CS.MsState.EDU>
Subject: Re: Re: NFS as a Cluster File System.
Date: Tue, 14 Jan 2003 10:01:32 -0600 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.33.0301140956490.14089-100000@disney.cs.msstate.edu>
References: <shsk7h720p9.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from walt.cs.msstate.edu
	([130.18.208.30] helo=CS.MsState.Edu ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YTVC-0002I7-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 08:01:22 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsk7h720p9.fsf@charged.uio.no>
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


> Note, though, that in addition to supporting file locking, NFSv4 adds
> support for file 'delegation' which allow the NFS client to do locking
> entirely as a local operation (i.e. there is no need to contact the
> server). For most applications, this will make locking a much faster
> operation...

  If file-locking is made local, how do other NFS-clients get to know the
locking info. I suspect this might lead to multiple NFS-clients holding
the lock on the same file simultaneously, leading to file-inconsistency.
Please correct me if Iam wrong.

Thanks,
-Kums

-- Kumaran Rajaram, Mississippi State University --
kums@cs.msstate.edu  <http://www.cs.msstate.edu/~kums>




-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
