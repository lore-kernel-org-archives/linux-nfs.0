From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: POSIX I/O on NFS with noac option
Date: Thu, 12 Apr 2007 13:10:07 -0400
Message-ID: <1176397807.6664.9.camel@heimdal.trondhjem.org>
References: <949021.41130.qm@web56603.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: AK <amithl_prem@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc2oY-0007Ox-MO
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:10:30 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+Qtufo+n9FV+WBxOJAbn27g28pA3oq4Jo=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hc2oW-0002RQ-I4
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:10:31 -0700
In-Reply-To: <949021.41130.qm@web56603.mail.re3.yahoo.com>
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

On Thu, 2007-04-12 at 09:59 -0700, AK wrote:
> Trying to get this POSIX I/O code to work on our machines.
> 
> Running it from a NFS v3 mounted scratch sapce, with 'noac' option: no
> caching attribute option.
> It fails to run: gives me err= -1 and errno = 5
> 
> Although this works without error on my NFS v3 mounted home
> directories. Which are mounted from the head node of our cluster(Linux
> based head node and compute nodes).
> 
> Where as the scratch sapce is mounted of our storage server(Solaris).
> Any thoughts on issues related to Solars hosting NFS server and Linux
> nfs client ..with noac options ???
> 
> Any idea ? Appreciate any feedback
> ~thanks - ak
> 
> #include <fcntl.h>
> #include <errno.h>
> #include <unistd.h>
> 
> main()
> {
>    struct flock lock;
>    int fd, err;
> 
>    lock.l_type = F_WRLCK;
>    lock.l_start = 0;
>    lock.l_whence = SEEK_SET;
>    lock.l_len = 100;
> 
>    fd = open("test", O_RDWR | O_CREAT, 0644);
> 
>    err = fcntl(fd, F_SETLKW, &lock);
> 
>    printf("err = %d, errno = %d\n", err, errno);
>    close(fd);
> }

1) Why would you need the 'noac' flag if you are using locking?

2) Have you checked that the portmapper, rpc.statd and rpc.lockd are
accessible from the client? You can probe that using the commands

        rpcinfo -t <servername> status
and
        rpcinfo -t <servername> nlockmgr

if you are using UDP mounts, you might want to use

        rpcinfo -u <servername> status
and
        rpcinfo -u <servername> nlockmgr

instead...

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
