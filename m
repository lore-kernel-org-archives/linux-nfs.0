From: Ruben van Royen <ruben@guidedbees.com>
Subject: Locking on HP-UX
Date: Tue, 7 May 2002 19:56:47 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020507195647.B27332@tor.guidedbees.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from node1755f.a2000.nl ([24.132.117.95] helo=ns.linux.bogus)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1759Cl-0004UK-00
	for <nfs@lists.sourceforge.net>; Tue, 07 May 2002 10:56:51 -0700
Received: from ruben by ns.linux.bogus with local (Exim 3.12 #1 (Debian))
	id 1759Ch-00079b-00
	for <nfs@lists.sourceforge.net>; Tue, 07 May 2002 19:56:47 +0200
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

Hi all, 

I'm having trouble getting file locking to work on hpux. I already searched
your archives, but cannot find the problem from there. 
I have statd and lockd running, and also set insecure_locks. All to no avail.
The request does arrive at the linux client, I can see the ip-nr. of the hpux
machine in /var/lib/nfs/statd/sm after trying to lock a file. But apperently 
the hp does not like the answer it receives. 

I'm running a redhat 7.2 server with 2.4.9-31 redhat kernel and hpux 11.00
on the client.

File locking does work from both sun and linux clients.

Ruben

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
