From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: questions about rpc and locks
Date: Tue, 30 Apr 2002 17:45:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020430174511.A21356@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 172ZtP-0002zH-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Apr 2002 08:50:15 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id RAA03171
          for <nfs@lists.sourceforge.net>; Tue, 30 Apr 2002 17:49:00 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g3UFjBG21476
	for nfs@lists.sourceforge.net; Tue, 30 Apr 2002 17:45:11 +0200
To: nfs@lists.sourceforge.net
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

I have 2 questions about the kernel rpc implementation.

1. What are the return codes (from rpc_call) and their meanings (or where
could I find that, I found that looking at the code itself was really hard).

2. Is it possible to know at what point the rpc call failed ? (from within the 
rpc_task struct, to determine whether the caller couldn't send or it didn't get
a response).

About lock.

3. When the client think it has a lock on a nfs file, but the server thinks the
client hasn't, what happens ? (because I think that sometimes you have to chose
between that and the reverse, the client think it hasn't a lock the server
thinks it has).

Thanks.

Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
