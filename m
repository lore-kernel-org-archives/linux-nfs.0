From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: silly-deleting symlinks?
Date: 01 Apr 2002 21:18:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsit7b6xe5.fsf@charged.uio.no>
References: <87hen5wrx4.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16s7Jv-00075C-00
	for <nfs@lists.sourceforge.net>; Mon, 01 Apr 2002 11:18:23 -0800
To: Philippe Troin <phil@fifi.org>
In-Reply-To: <87hen5wrx4.fsf@ceramic.fifi.org>
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

>>>>> " " == Philippe Troin <phil@fifi.org> writes:

     > I've just noticed that nfsd tries to silly-delete symlinks.
     > Server: vanilla 2.2.20 SMP Client: vanilla 2.4.18 SMP Mount
     > options: rw,nodev,v2,rsize=8192,wsize=8192,hard,intr,udp,lock

     > Sometimes I see some .nfs<XXXX> files which are symlinks. How
     > can symlinks be "in use" and be subject to silly-deletion?

Sillydelete just looks at the number of counts on the dentry. If the
count is > 1 then the dentry is deemed to be 'in use' no matter what
the type of inode.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
