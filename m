From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: tunneling of nfs and nfs locks
Date: 19 Mar 2002 16:38:14 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswuw8y3dl.fsf@charged.uio.no>
References: <20020319161229.B10434@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nLhI-0002Ju-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 07:38:48 -0800
To: Dumas Patrice <dumas@centre-cired.fr>
In-Reply-To: <20020319161229.B10434@zeus.centre-cired.fr>
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

>>>>> " " == Dumas Patrice <dumas@centre-cired.fr> writes:

     > I have a running rpc_psrv serveur which forwards the rpc
     > requests with rpc numbers 201000 and 200003 to host "remote" ;
     > service 201000 is forwarded as 100005 on "remote" and 200003 as
     > 100003. after mount /file_on_remote I can access the files
     > which are on remote in /file_on_remote, but the locking
     > mechanism doesn't work (I test it with mutt, as it reports that
     > he couldn't make a lock, maybe there could be cleaner ways to
     > test for it...).

     > Is it normal that the locking fails in this situation (nfs
     > forwarded) ? What could I do to have it work ?

Locking uses a different protocol. It relies on using the portmapper
to look up RPC service number 100021. For that reason, it will just
find the ordinary lockd manager on localhost...

     > This may be unrelated, or not : there is a strange thing which
     > happen when I do, on "local": umount /file_on_remote It
     > responds: Cannot MOUNTPROG RPC: RPC: Programm not registered

Yeah. umount has a hack that sends a MOUNTPROC_UMNT call to the
server. Unfortunately it ignores all options such as 'mountport='.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
