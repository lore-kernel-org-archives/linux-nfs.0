From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFS as a Cluster File System.
Date: Sun, 12 Jan 2003 22:23:13 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15905.56513.503358.135654@charged.uio.no>
References: <F155FnqdR2xuRoAnbsZ00020983@hotmail.com>
	<shs3co1kq1e.fsf@charged.uio.no>
	<20030110173820.GA3066@wumpus.attbi.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18XpZh-0001OL-00
	for <nfs@lists.sourceforge.net>; Sun, 12 Jan 2003 13:23:21 -0800
To: Greg Lindahl <lindahl@keyresearch.com>
In-Reply-To: <20030110173820.GA3066@wumpus.attbi.com>
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

>>>>> " " == Greg Lindahl <lindahl@keyresearch.com> writes:

     > Metadata is solved by noac.
 
Nope. 'noac' doesn't even do that for you:

'noac' just increases the frequency of GETATTR calls. It will not
suffice to provide consistent metadata for those operations that
actually depend on the returned values, as there will be no atomicity
guarantees between the GETATTR call and the subsequent
READ/WRITE/READDIR/...

A common example where this is relevant: You have absolutely no
guarantee with 'noac' that open("foo",O_APPEND,O_WRONLY), will work as
expected.

So, again I repeat: File locking is the only way to ensure cache
coherency.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
