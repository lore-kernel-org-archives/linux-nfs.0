From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: Re: patchs for lockd: granted_res_proc, client address check, blocking check
Date: Tue, 30 Apr 2002 18:26:46 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020430182646.C21356@zeus.centre-cired.fr>
References: <20020423103152.A3624@zeus.centre-cired.fr> <20020425155951.E13292@zeus.centre-cired.fr> <shsznzqzt0q.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 172aXc-0000q3-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Apr 2002 09:31:48 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id SAA03995
          for <nfs@lists.sourceforge.net>; Tue, 30 Apr 2002 18:30:35 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g3UGQkq21538
	for nfs@lists.sourceforge.net; Tue, 30 Apr 2002 18:26:46 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <shsznzqzt0q.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Fri, Apr 26, 2002 at 11:52:21AM +0200
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

Hi,

> Just add a call to posix_test_lock() in nlmclnt_grant().

I don't think it will work because posix_test_lock() will find that the locks
have the same owner and thus return 0 as if the lock wasn't found. A workaround
would be to set the fl_owner of the file_lock from the granted_msg to a value
which will cause locks_same_owner to fail, and after that try
nlm_compare_locks with the resulting lock.

Am I right ? If so could setting fl_owner to NULL break something ?

Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
