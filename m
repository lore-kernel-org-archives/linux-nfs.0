From: Jason Holmes <jholmes@psu.edu>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 09:16:43 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB3924B.7450E9F7@psu.edu>
References: <3FB27670.4C878A84@psu.edu>
		<shssmkttk34.fsf@charged.uio.no>
		<3FB29D43.A618973D@psu.edu>
		<16306.41898.291062.36209@charged.uio.no>
		<3FB2A738.3F2C90B8@psu.edu>
		<16306.49310.195265.145519@charged.uio.no>
		<3FB2DC60.FA7D3E08@psu.edu> <16306.59249.857512.354675@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKIH6-0006vh-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 06:16:44 -0800
Received: from vpn-19-5.aset.psu.edu ([146.186.19.5] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AKIH5-0001db-OF
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 06:16:43 -0800
To: trond.myklebust@fys.uio.no
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond Myklebust wrote:
> 
> >>>>> " " == Jason Holmes <jholmes@psu.edu> writes:
> 
>      > FWIW, I ran the test with nfsvers=2 (with the export still
>      > being async) and it finished in 112.53user 45.02system
>      > 2:43.50elapsed 96%CPU.
> 
> For comparison, on my own machine, I get stats of the form:
> 
> Client rpc stats:
> calls      retrans    authrefrsh
> 248291     6225       0
> Client nfs v2:
> null       getattr    setattr    root       lookup     readlink
> 0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
> read       wrcache    write      create     remove     rename
> 0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
> link       symlink    mkdir      rmdir      readdir    fsstat
> 0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
> 
> Client nfs v3:
> null       getattr    setattr    lookup     access     readlink
> 0       0% 77      0% 0       0% 60      0% 94      0% 0       0%
> read       write      create     mkdir      symlink    mknod
> 0       0% 240378 96% 8       0% 0       0% 0       0% 0       0%
> remove     rmdir      rename     link       readdir    readdirplus
> 33      0% 0       0% 0       0% 0       0% 0       0% 12      0%
> fsstat     fsinfo     pathconf   commit
> 0       0% 1       0% 0       0% 7628    3%
> 
> Any hints on how I can reproduce your results?

Unfortunately Gaussian's licensing would prohibit me from passing it
along to reproduce this.  I'll try to reproduce this with another
program this morning and get back to you.

Thanks,

--
Jason Holmes


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
