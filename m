From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFS as a Cluster File System.
Date: Tue, 14 Jan 2003 17:08:15 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15908.13807.645028.97829@charged.uio.no>
References: <shsk7h720p9.fsf@charged.uio.no>
	<Pine.GSO.4.33.0301140956490.14089-100000@disney.cs.msstate.edu>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YTbz-0003RE-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 08:08:23 -0800
To: Kumaran Rajaram <kums@CS.MsState.EDU>
In-Reply-To: <Pine.GSO.4.33.0301140956490.14089-100000@disney.cs.msstate.edu>
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

>>>>> " " == Kumaran Rajaram <kums@CS.MsState.EDU> writes:

     >   If file-locking is made local, how do other NFS-clients get
     >   to know the
     > locking info. I suspect this might lead to multiple NFS-clients
     > holding the lock on the same file simultaneously, leading to
     > file-inconsistency.  Please correct me if Iam wrong.

I suggest you read RFC3010, as this is what the file delegation takes
care of.

Delegation is a way for the server to tell the client that it is the
only current user of that particular file. If another client comes
along and opens the same file, then the server must notify the first
client that it is about to revoke the delegation, and give it a short
period of time in which to flush back all changes (including any locks
that are being held).

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
