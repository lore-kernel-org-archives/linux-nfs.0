From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: Re: mountd segfault on itanium2
Date: Mon, 3 May 2004 08:35:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040503133546.GA25469@rx8.ibm.com>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu> <20040501030730.GE23287@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKdci-00020k-EQ
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 06:36:44 -0700
Received: from e6.ny.us.ibm.com ([32.97.182.106])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BKdci-0002yn-3h
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 06:36:44 -0700
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: <20040501030730.GE23287@polop.usc.edu> (from garrick@usc.edu on Fri, Apr 30, 2004 at 22:07:30 -0500)
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

On 04/30/04 22:07:30, Garrick Staples wrote:
> I have an ugly work-around that seems to be working.  It seems that 2.6 has a
> new nfs interface for userspace.  By forcing mountd to use the older 2.4
> interface, it doesn't segfault anymore.  So something in the new code paths is
> broken.
> 
> In support/nfs/cachio.c:
> int
> check_new_cache(void)
> {
>         struct stat stb;
> 
>         return 0;  /* DISABLE NEW 2.6 INTERFACE */
> 
>         return  (stat("/proc/fs/nfs/filehandle", &stb) == 0) ||
>                 (stat("/proc/fs/nfsd/filehandle", &stb) == 0);
> }

If you want to use the old syscall interface, all you need to do is make 
sure nfsd is not mounted in /proc/fs/nfsd.

> Am I losing any functionality by doing this?  I can't actually find any
> problems.

I think there are no functionality losses but I have seen issues with using
the syscall interface on large memory systems.  The syscall mount and 
unmount the nfsdfs for every syscall.  This will cause the inode and dentry
for this filesystem to be flush, but in order to do that it needs to walk 
through all inode and dentry caches under lock.  If you have a system with
16GB of ram, mounting and unmounting can take a really long time.

-JRS


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
