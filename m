From: Jason Holmes <jholmes@psu.edu>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Wed, 12 Nov 2003 15:51:15 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB29D43.A618973D@psu.edu>
References: <3FB27670.4C878A84@psu.edu> <shssmkttk34.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AK1xn-0006wR-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 12:51:43 -0800
Received: from vpn-19-18.aset.psu.edu ([146.186.19.18] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AK1xm-0003RK-Jz
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 12:51:42 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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
>      > Can someone clue me in as to why this may be happening and if
>      > it's a "bug" or not?
> 
> Large numbers of 'commit' operations are a typical sign of the memory
> management going wild. Have you compared this to the standard
> 2.6.0-test9 kernel?
> 
> What sort of load did you otherwise have on that machine?

The machines (both client and server) are idle other than the testing
I'm doing and I'm doing only one test at a time at this point.

I did not do plain 2.6.0-test9 yet, but here is 2.6.0-test6 and
2.6.0-test9-bk17:

-- 2.6.0-test6 --

Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 749     0% 0       0% 130     0% 251     0% 0       0%
read       write      create     mkdir      symlink    mknod
833     0% 178577 14% 24      0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
24      0% 0       0% 0       0% 0       0% 18      0% 1       0%
fsstat     fsinfo     pathconf   commit
0       0% 3       0% 0       0% 1024801 85%

Client rpc stats:
calls      retrans    authrefrsh
1205411    7          0

-- 2.6.0-test9-bk17 --

Client nfs v3:
null       getattr    setattr    lookup     access     readlink  
0       0% 744     0% 0       0% 129     0% 252     0% 0       0%
read       write      create     mkdir      symlink    mknod     
873     0% 178574 14% 24      0% 0       0% 0       0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
24      0% 0       0% 0       0% 0       0% 18      0% 0       0%
fsstat     fsinfo     pathconf   commit     
0       0% 3       0% 0       0% 1023451 84%

Client rpc stats:
calls      retrans    authrefrsh
1204092    3          0

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
