From: Jason Holmes <jholmes@psu.edu>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Wed, 12 Nov 2003 20:20:32 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB2DC60.FA7D3E08@psu.edu>
References: <3FB27670.4C878A84@psu.edu>
			<shssmkttk34.fsf@charged.uio.no>
			<3FB29D43.A618973D@psu.edu>
			<16306.41898.291062.36209@charged.uio.no>
			<3FB2A738.3F2C90B8@psu.edu> <16306.49310.195265.145519@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AK69y-0001WN-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 17:20:34 -0800
Received: from vpn-19-5.aset.psu.edu ([146.186.19.5] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AK69y-0006W7-B9
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 17:20:34 -0800
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
>      > I wasn't, but I'm recompiling test9-bk17 with all of the
>      > debugging options turned on right now.  Is there anything in
>      > particular you want me to do?
> 
> Come to think of it, could you try running with and without the patch
> on
> 
>   http://www.fys.uio.no/~trondmy/src/Linux-2.6.x/2.6.0-test9/linux-2.6.0-01-fix_deadlock.dif
> 
> That fixes a race that is likely to show up when memory is
> low. Normally it should cause a deadlock rather than corruption, but
> it is conceivable that there are other side-effects...
> 
> Please make sure that you run with slab debugging enabled...

With all debugging enabled, test9-bk17:

patched:   112.21user 259.86system 10:53.48elapsed 56%CPU
unpatched: 112.17user 252.35system 10:37.43elapsed 57%CPU

-- patched --

Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 752     0% 0       0% 134     0% 260     0% 0       0% 
read       write      create     mkdir      symlink    mknod      
873     0% 178571 14% 24      0% 0       0% 0       0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
24      0% 0       0% 0       0% 0       0% 18      0% 0       0% 
fsstat     fsinfo     pathconf   commit     
0       0% 3       0% 0       0% 1044537 85%

Client rpc stats:
calls      retrans    authrefrsh
1225196    8          0

-- unpatched -- 

Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 753     0% 0       0% 134     0% 260     0% 0       0% 
read       write      create     mkdir      symlink    mknod      
873     0% 178575 14% 24      0% 0       0% 0       0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
24      0% 0       0% 0       0% 0       0% 18      0% 0       0% 
fsstat     fsinfo     pathconf   commit     
0       0% 3       0% 0       0% 1050417 85%

Client rpc stats:
calls      retrans    authrefrsh
1231081    5          0

I didn't see anything to indicate that any debug code had triggered (I'm
assuming that if it did the kernel would give an OOPS?)

FWIW, I ran the test with nfsvers=2 (with the export still being async)
and it finished in 112.53user 45.02system 2:43.50elapsed 96%CPU.

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
