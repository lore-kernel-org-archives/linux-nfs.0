From: Chuck Lever <cel@citi.umich.edu>
Subject: [BUG RPT] Cthon '02 lock test fails on 2.5.38 with TCP only
Date: Fri, 27 Sep 2002 11:36:44 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0209271127530.1793-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17uxAg-0002wo-00
	for <nfs@lists.sourceforge.net>; Fri, 27 Sep 2002 08:36:50 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

hi trond-

we already know locking is not working right in 2.5... this is FYI.

connectathon lock test #1 fails on 2.5.38 against both a Solaris 2.9 NFS
server and a NetApp filer when mounting with TCP.  UDP mount finishes all
tests with only a single warning.  problem not exhibited with 2.4.18-10.  
problem does not occur if "nolock" mount option is specified during test.

console output:

 ...

Starting LOCKING tests: test directory /mnt/bay/dexter.test (arg: -t)

Testing native post-LFS locking

Creating parent/child synchronization pipes.

Test #1 - Test regions of an unlocked file.
	Parent: 1.1  - F_TEST  [       0,       1] FAILED!
	Parent: **** Expected success, returned errno=5...
	Parent: **** Probably implementation error.

** PARENT pass 1 results: 0/0 pass, 0/0 warn, 1/1 fail (pass/total).

**  CHILD pass 1 results: 0/0 pass, 0/0 warn, 0/0 fail (pass/total).
lock tests failed
leaving /mnt/bay mounted
[cel@dexter cthon02]$ mount

 ...

bay:/export/cel on /mnt/bay type nfs 
(rw,hard,intr,tcp,lock,rsize=32768,wsize=32768,addr=141.211.133.78)
[cel@dexter cthon02]$

-- 

corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
