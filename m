From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: Re: questions about rpc and locks
Date: Thu, 2 May 2002 18:41:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020502184121.B22985@zeus.centre-cired.fr>
References: <20020430174511.A21356@zeus.centre-cired.fr> <shsk7qoqd4f.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 173Jio-0004eW-00
	for <nfs@lists.sourceforge.net>; Thu, 02 May 2002 09:46:22 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id SAA01012
          for <nfs@lists.sourceforge.net>; Thu, 2 May 2002 18:45:27 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g42GfLn23938
	for nfs@lists.sourceforge.net; Thu, 2 May 2002 18:41:21 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <shsk7qoqd4f.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Wed, May 01, 2002 at 02:14:08PM +0200
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

Thanks for your reply.

> If the call could not be made, then that value will reflect an error
> code, usually EINTR (although for 'soft' RPC calls, the error EIO will
> be returned if a major timeout occurred).
....
> Only makes sense for 'soft' RPC calls, and in that case you get an EIO.

In case of an asynchronous call, is there such a difference between 'soft' and
'hard' rpc calls too ?

I haven't seen anywhere what was the kind of rpc call of the server side lockd.
Is it hard by default ?

Pat

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
