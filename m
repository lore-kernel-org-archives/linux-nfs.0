From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: lockd clients and server have the same rpc_clnt for each host
Date: Wed, 15 May 2002 18:35:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020515183511.E27252@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1781kZ-0003Zu-00
	for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 09:35:39 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id SAA01515
          for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 18:34:29 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g4FGZB527312
	for nfs@lists.sourceforge.net; Wed, 15 May 2002 18:35:11 +0200
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

I admit the subject is rather cryptic. Here is the explaination.

It seems to me that the hosts structure is common to all the lockd clients and
the lockd server. Is it true (because nlm_hosts is a static array) ?

If it is true, then it seems to me that there is a problem with the fact that
the rpc clients are tied to hosts. If there is a client allready defined, it is
used, although it may have incorrect settings with respect with softrtry,
chatty and intr. Otherwise said, the first rpc call determines the client
options. I think this is not what should be.

Should I try to correct it (if the hosts are really shared) ?

Pat

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
