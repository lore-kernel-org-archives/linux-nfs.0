From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: requests for lockd
Date: Fri, 17 May 2002 17:03:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020517170322.B1000@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178jGe-0000cE-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 08:03:40 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id RAA00615
          for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 17:02:35 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g4HF3Ma01167
	for nfs@lists.sourceforge.net; Fri, 17 May 2002 17:03:22 +0200
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

I have 3 requests. Could you please tell me if these features will be accepted
or not.

1) client side:
have a nlm_prog or lockprog as option for mount, which says which rpc
program number to use with lockd.

2) server side:
Monitor the caller_name instead of the rpc_peer.

3) client side:
Implement a new callback for a client to be noticed which host to monitor for a
given lock or a given nlm_prog (in case 1) is accepted).




These features are required and sufficient to have lockd tunneling through ssh
with snfs working properly even when there is a reboot.

Pat

N.B. if I were you, I would reject the 3), but who knows ;-).

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
