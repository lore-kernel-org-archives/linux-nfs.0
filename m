From: Dumas Patrice <dumas@centre-cired.fr>
Subject: Re: standard and lockd
Date: Thu, 11 Apr 2002 14:06:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020411140614.I23570@zeus.centre-cired.fr>
References: <20020410165023.D23279@zeus.centre-cired.fr> <shslmbvlbm6.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vdOk-00018k-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Apr 2002 05:09:55 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id OAA04070
          for <nfs@lists.sourceforge.net>; Thu, 11 Apr 2002 14:09:06 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g3BC6EA24840
	for nfs@lists.sourceforge.net; Thu, 11 Apr 2002 14:06:14 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <shslmbvlbm6.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Wed, Apr 10, 2002 at 07:14:25PM +0200
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

> I don't follow you at all here. Examples please of where this is a
> problem with the standard?

There is a problem with my sillyness. I didn't read the sources carefully, I
found all the relevant piece now, sorry for the bothering.

> See the comment about HP clients above nlmsvc_grant_blocked().

I saw it, and I think the associated hack do things quite well.
 
> Of course, if you are planning on writing proper support for the
> asynchronous RPC, then we can indeed go ahead and make
> nlmsvc_grant_blocked() call either NLM_GRANTED or NLM_GRANTED_MSG
> depending on whether the client originally called NLM_LOCK or
> NLM_LOCK_MSG.

That was what I was thinking about, maybe with a fallback to NLM_GRANTED_MSG
when some time has passed, to get around HP clients (in case the original call
was with NLM_LOCK). I don't know if this happen in real life, but we could
imagine some client processing only NLM_GRANTED callbacks if they send NLM_LOCK
or maybe totally lacking support for NLM_GRANTED_MSG and the like.

Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
