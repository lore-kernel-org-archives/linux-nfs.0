From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd clients and server have the same rpc_clnt for each host
Date: 16 May 2002 12:24:35 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsadr0gzks.fsf@charged.uio.no>
References: <20020515183511.E27252@zeus.centre-cired.fr>
	<shs7km5cfzq.fsf@charged.uio.no>
	<20020516103046.C28325@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178IRa-0002J5-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 03:25:10 -0700
To: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
In-Reply-To: <20020516103046.C28325@zeus.centre-cired.fr>
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

>>>>> " " == Patrice DUMAS <dumas@centre-cired.fr> writes:

     > To do that, there should be a way to differenciate between
     > different clients and the server. Have the different clients a
     > different pid, also different from the server (or the kernel
     > equivalent of a pid), and how can I get that information ?

The server should always be indexing entries by the struct svc_client
(which of course does not exist for the client).

IOW the code could instead simply read

static inline int
nlm_match_host(struct nlm_host *host, struct svc_client *clnt,
                                        struct sockaddr_in *sin)
{
        if (clnt || host->h_exportent)
                return host->h_exportent == clnt;
        return nlm_cmp_addr(&host->h_addr, sin);
}

Of course, keeping 2 separate lists would make a lot of sense, and
could allow us to make other rationalizations.

     > Also, I had another idea in order to fix it. Just keep the
     > hosts common, but add a chained list of clients differing by
     > the softrtry, chatty,... to the host. Then change nlm_bind_host
     > to add a support for different clients matching. I prefer this
     > solution because in the GRANT implementation I did, there is a
     > need to change the softrtry and this could interfere with other
     > calls from the server if there is just one client for a host.

Not sure I understand this. Why do you need soft in one case, and not
soft in the other?

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
