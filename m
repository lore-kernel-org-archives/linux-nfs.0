From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: POSIX I/O on NFS with noac option
Date: Thu, 12 Apr 2007 13:56:47 -0400
Message-ID: <1176400607.6664.31.camel@heimdal.trondhjem.org>
References: <757173.20715.qm@web56601.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: AK <amithl_prem@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc3Xa-0003qT-HW
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:57:02 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18wRr51Jr+qKyfI2+ttzmxFKV/5fByWLok=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hc3Xc-0006Es-CL
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:57:05 -0700
In-Reply-To: <757173.20715.qm@web56601.mail.re3.yahoo.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-04-12 at 10:42 -0700, AK wrote:
> Thank you Trond for your reply ... 
>  
> >>1) Why would you need the 'noac' flag if you are using locking?
> part of the requirement for MPI-IO to work correctly on NFS mounts.

Hmm... That sounds extremely dodgy... 'noac' does nothing to ensure
cache consistency. All it does is to turn of caching of attributes
across system calls.

> >>2) Have you checked that the portmapper, rpc.statd and rpc.lockd are
> >>accessible from the client? You can probe that using the commands
>  
> On Client I have checked that portmap(rpc) rpc.statd(rpcuser) and
> lockd(root) is running but not rpc.lockd

lockd is the kernel process that takes the place of rpc.lockd on Linux
machines. It sounds like your client setup is fine.

> On server, there is no portmap, rpc.statd, rpc.lock nor lockd
> running. 
>  
> Upon the following probes on CLIENT I get the following
> >>
> >>rpcinfo -t status
> >>and
> >>rpcinfo -t nlockmgr
> >>
> # rpcinfo -t <myserver> status
> rpcinfo: RPC: Program not registered
> program 100024 is not available
>  
> # rpcinfo -t <myserver> nlockmgr
> rpcinfo: RPC: Program not registered
> program 100021 is not available
> 
> >>if you are using UDP mounts, you might want to use
> >>
> >>rpcinfo -u status
> >>and
> >>rpcinfo -u nlockmgr
> 
> # rpcinfo -u <myserver> status
> rpcinfo: RPC: Program not registered
> program 100024 is not available
>  
> # rpcinfo -u <myserver> nlockmgr
> rpcinfo: RPC: Program not registered
> program 100021 is not available
> 
> >>instead...
> 
> Some info from SERVER 
> # rpcinfo -u localhost nfs
> program 100003 version 2 ready and waiting
> program 100003 version 3 ready and waiting
>  
> # rpcinfo -p | grep nfs
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100227    2   udp   2049  nfs_acl
>     100227    3   udp   2049  nfs_acl
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100227    2   tcp   2049  nfs_acl
>     100227    3   tcp   2049  nfs_acl
> # modinfo | egrep "nfs|lock"
>  42 7828855a   1d3e  87   1  todds1287 (ds1287 clock driver 1.8)
> 156 78428000  2b018 106   1  nfs (NFS syscall, client, and common)
> 156 78428000  2b018 106   1  nfs (NFS syscall, client, and common)
> 156 78428000  2b018  16   1  nfs (network filesystem)
> 156 78428000  2b018   7   1  nfs (network filesystem version 2)
> 156 78428000  2b018  17   1  nfs (network filesystem version 3)
> 159 78458000  12881   -   1  nfssrv (NFS server module)
> 
> >>Trond
> Form the above outputs it doesn't look like they are running. Is this
> required, if yes, then 
> how do I turn them ON. And Why didn't we requires it for general
> purpose NFS use ?? We have been running this server for about 2 years
> now. 

If it has been running for 2 years, then I'd say you clearly haven't
been using locking over NFS against it.

Check your Solaris admin manual for details on how to turn on the
locking manager and lock status daemon.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
