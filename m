From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: binaries becoming corrupt on nfs
Date: Wed, 16 Mar 2005 17:56:49 -0500
Message-ID: <1111013809.14687.22.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
	 <1110835899.19295.42.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0503141434390.4702@harp.ngdc.noaa.gov>
	 <1110836857.24466.4.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0503141456140.4702@harp.ngdc.noaa.gov>
	 <1110838426.24466.17.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0503161535280.2370@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBhRm-0004Iq-Ol
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 14:57:02 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DBhRl-0004Td-6F
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 14:57:02 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0503161535280.2370@harp.ngdc.noaa.gov>
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

on den 16.03.2005 Klokka 15:40 (-0700) skreiv Ara.T.Howard:
> i'm still seeing this issue even though NO copying is occuring on mmap'd
> binaries.  the process used is now the built-in install program
> 
>    install: all
>            $(install_prog) grid_ols/grid_ols $(bindir)
>            $(install_prog) subset/subset $(bindir)
> 
> install does not copy, it unlinks the dest and then writes a new file:
> 
>    jib:~/shared/dmspnl_new > strace install a b 2>&1 | tail -13
>    unlink("b")                             = 0
>    open("a", O_RDONLY|O_LARGEFILE)         = 3
>    fstat64(3, {st_mode=S_IFREG|0664, st_size=0, ...}) = 0
>    open("b", O_WRONLY|O_CREAT|O_LARGEFILE, 0100664) = 4
>    fstat64(4, {st_mode=S_IFREG|0664, st_size=0, ...}) = 0
>    fstat64(3, {st_mode=S_IFREG|0664, st_size=0, ...}) = 0
>    read(3, "", 8192)                       = 0
>    close(4)                                = 0
>    close(3)                                = 0
>    chmod("b", 0600)                        = 0
>    chown32("b", -1, -1)                    = 0
>    chmod("b", 0755)                        = 0
>    exit_group(0)                           = ?
> 
> if i run 'make install' while these binaries are running on our cluster
> (almost ensuring more than one of them has the file mmap'd) i will see some
> small random number of nodes with corrupt caches begin to have every
> subsequent run of the binary fail.

How are they corrupt?

Cheers,
 Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
