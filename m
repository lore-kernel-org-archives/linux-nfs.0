From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RH 7.3 kernels and NFS performance
Date: 07 Aug 2002 17:55:25 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsfzxqd5oy.fsf@charged.uio.no>
References: <3D513E56.CAF735B6@lmco.com>
	<200208071037.39377.rdieter@math.unl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,  jeffrey.b.layton@lmco.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cT9u-0006T6-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 08:55:38 -0700
To: Rex Dieter <rdieter@math.unl.edu>
In-Reply-To: <200208071037.39377.rdieter@math.unl.edu>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Rex Dieter <rdieter@math.unl.edu> writes:

     > The Hit is big and bad.  When using the default NFS export
     > options (in particular sync), I see NFS write performance of
     > ~50k with the 2.4.18-5 kernels.  When set async, performance
     > comes back up to par.  I can give you the bugzilla # I reported
     > it under, if you like.

That is *not* a bug. The NFS protocol does not actually allow for the
sort of behaviour that 'async' provides. The main problem is that
actions like 'fsync()' on the client can no longer guarantee that the
data is physically written to disk on the server. IOW if the server
crashes, your data is lost...

The new default of 'sync' for exports is quite correct and should only
be changed by people who are aware of the consequences for data
integrity.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
