From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: Re: lockd clients and server have the same rpc_clnt for each host
Date: Thu, 16 May 2002 10:30:46 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020516103046.C28325@zeus.centre-cired.fr>
References: <20020515183511.E27252@zeus.centre-cired.fr> <shs7km5cfzq.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178Gg7-0002Cw-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 01:32:03 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id KAA21541
          for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 10:30:06 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g4G8Uk928432
	for nfs@lists.sourceforge.net; Thu, 16 May 2002 10:30:46 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <shs7km5cfzq.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Wed, May 15, 2002 at 10:28:57PM +0200
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

> 
>      > It seems to me that the hosts structure is common to all the
>      > lockd clients and the lockd server. Is it true (because
>      > nlm_hosts is a static array) ?
> 
> The structure is common, but the entries shouldn't be.
> 
> Hmm... It looks like nlm_match_host() might want a small fix in order
> to take that into account...

;-)

To do that, there should be a way to differenciate between different clients
and the server. Have the different clients a different pid, also different from
the server (or the kernel equivalent of a pid), and how can I get that 
information ?


Also, I had another idea in order to fix it. Just keep the hosts common, but
add a chained list of clients differing by the softrtry, chatty,... to the 
host. Then change nlm_bind_host to add a support for different clients
matching. I prefer this solution because in the GRANT implementation I did,
there is a need to change the softrtry and this could interfere with other
calls from the server if there is just one client for a host.

What do you think about that ?

Pat

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
