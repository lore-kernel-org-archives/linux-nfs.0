From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: Re: lockd clients and server have the same rpc_clnt for each host
Date: Thu, 16 May 2002 14:46:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020516144613.B28466@zeus.centre-cired.fr>
References: <20020515183511.E27252@zeus.centre-cired.fr> <shs7km5cfzq.fsf@charged.uio.no> <20020516103046.C28325@zeus.centre-cired.fr> <shsadr0gzks.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178Kf7-0004YQ-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 05:47:18 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id OAA27468
          for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 14:45:38 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g4GCkDB28649
	for nfs@lists.sourceforge.net; Thu, 16 May 2002 14:46:13 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <shsadr0gzks.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Thu, May 16, 2002 at 12:24:35PM +0200
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

> The server should always be indexing entries by the struct svc_client
> (which of course does not exist for the client).

This will clean things for client/server mix, but not for client/client mix.

Just suppose a client is waiting for a lock, and another lock is requested, but
with different softtrtry, etc... settings. The second one will use the same 
than the first (from nlmclnt_proc):

        /* Create RPC client handle if not there, and copy soft
         * and intr flags from NFS client. */
        if (host->h_rpcclnt == NULL) {
                struct rpc_clnt *clnt;

                /* Bind an rpc client to this host handle (does not
                 * perform a portmapper lookup) */
                if (!(clnt = nlm_bind_host(host))) {
                        status = -ENOLCK;
                        goto done;
                }
                clnt->cl_softrtry = nfssrv->client->cl_softrtry;
                clnt->cl_intr     = nfssrv->client->cl_intr;
                clnt->cl_chatty   = nfssrv->client->cl_chatty;
        }


> IOW the code could instead simply read
> 
> static inline int
> nlm_match_host(struct nlm_host *host, struct svc_client *clnt,
>                                         struct sockaddr_in *sin)
> {
>         if (clnt || host->h_exportent)
>                 return host->h_exportent == clnt;
>         return nlm_cmp_addr(&host->h_addr, sin);
> }

Your stuff should be right to isolate server and clients hosts.
The nlmclnt_lookup_host in server code should also be replaced with
nlmsvc_lookup_host... hoping it won't break anything ;-).

> Not sure I understand this. Why do you need soft in one case, and not
> soft in the other?

In case the client asked with LOCK (and not LOCK_MSG), the server will try to
grant the lock with GRANTED. However some clients only accept GRANTED_MSG even
if they asked with LOCK. If the call is hard, the server will never know that
the client doesn't respond to the GRANTED call. My strategy is be to do the
GRANTED call soft, and revert to GRANTED_MSG if getting an EIO. (the
GRANTED_MSG being still hard). Does it make sense ?

Pat

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
