From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: Re: Need help
Date: Fri, 9 Aug 2002 16:10:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020809161000.A30236@hermes.centre-cired.fr>
References: <028b01c2400b$3e4b10c0$df0838d2@bhatti>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17dAhr-0002aM-00
	for <nfs@lists.sourceforge.net>; Fri, 09 Aug 2002 07:25:35 -0700
Received: from hermes.centre-cired.fr ([193.51.120.92])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id QAA13838
          for <nfs@lists.sourceforge.net>; Fri, 9 Aug 2002 16:23:05 +0100 (WEST)
Received: (from dumas@localhost)
	by hermes.centre-cired.fr (8.11.6/8.11.6) id g79EA1r30287
	for nfs@lists.sourceforge.net; Fri, 9 Aug 2002 16:10:01 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <028b01c2400b$3e4b10c0$df0838d2@bhatti>; from farooq.bhatti@comsats.net.pk on Fri, Aug 09, 2002 at 06:14:14PM -0700
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

Are you sure that portmap is running on the server (and client), and that
your ip is allowed ?
Is the mounts programm listed in 

$ rpcinfo -p <server>

?

Pat

> My both client and server are Linux redhat 7.2 box and 
> I am getting following error when I mount the file system
> 
> mount: RPC: Program not registered


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
