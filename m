From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [USN-36-1] NFS statd vulnerability
Date: Fri, 3 Dec 2004 14:34:37 +1100
Message-ID: <16815.57037.809107.765969@cse.unsw.edu.au>
References: <20041201143603.GA15315@box79162.elkhouse.de>
	<1101951155.32266.47.camel@lade.trondhjem.org>
	<1101951953.32266.51.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    Martin Pitt <martin.pitt@canonical.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ca4Db-0004O0-CU
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 19:34:51 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ca4DZ-0006Kv-6C
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 19:34:50 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Wednesday December 1
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wednesday December 1, trond.myklebust@fys.uio.no wrote:
> on den 01.12.2004 Klokka 20:32 (-0500) skreiv Trond Myklebust:
> > on den 01.12.2004 Klokka 15:36 (+0100) skreiv Martin Pitt:
> > 
> > > SGI discovered a remote Denial of Service vulnerability in the NFS
> > > statd server. statd did not ignore the "SIGPIPE" signal which caused
> > > it to shutdown if a misconfigured or malicious peer terminated the TCP
> > > connection prematurely.
> > 
> > WTF wasn't this first fixed in the actual upstream nfs-utils package?
> > WTF are we only hearing of this now via bugtraq?
> > 
> > Grrr.....
> 
> Neil, this appears to be the hunk in question.

Ho humm.... yes, thanks. I have pushed it into CVS and will try to
make a new tarball soon.

Anyone who is anxious about this (i.e. doesn't have statd suitable
firewalled) can put 

    trap '' PIPE

in the shell script that runs statd, and it will have the same effect.

NeilBrown


> 
> Cheers,
>   Trond
> 
> -- 
> Trond Myklebust <trond.myklebust@fys.uio.no>
> 
>  statd.c |    5 +++++
>  1 files changed, 5 insertions(+)
> 
> Index: NFS@sourceforge.net/nfs-utils/utils/statd/statd.c
> ===================================================================
> --- NFS@sourceforge.net.orig/nfs-utils/utils/statd/statd.c	2004-09-05 22:15:51.000000000 -0400
> +++ NFS@sourceforge.net/nfs-utils/utils/statd/statd.c	2004-12-01 20:40:45.797338534 -0500
> @@ -422,6 +422,11 @@ int main (int argc, char **argv)
>  	signal(SIGUSR1, sigusr);
>  	/* WARNING: the following works on Linux and SysV, but not BSD! */
>  	signal(SIGCHLD, SIG_IGN);
> +	/*
> +	 * Ignore SIGPIPE to avoid statd dying when peers close their
> +	 * TCP connection while we're trying to reply to them.
> +	 */
> +	signal(SIGPIPE, SIG_IGN);
>  
>  	/* initialize out_port */
>  	statd_get_socket(out_port);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
