From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 10:36:13 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1082730973.2617.23.camel@lade.trondhjem.org>
References: <40892507.2030004@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH1ms-0001fS-5Y
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 07:36:18 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BH1mr-0006tf-Tz
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 07:36:18 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40892507.2030004@RedHat.com>
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

On Fri, 2004-04-23 at 10:15, Steve Dickson wrote:
> Here is a 2.4 patch that will reinstantiate an inode
> when a ESTALE error is returned on a getattr. When
> the error occurs, a lookup is immediately issued
> to get a new fh.
> 
> The fixes the problem of a server rsync -a directory
> that a client has mounted. The key being the -a flag
> since it causes the server not to update the mtime on
> the directory.
> 
> My initial efforts was to make nfs_lookup_revalidate()
> a bit smarter with the use of ctimes but turns out
> that when nfs_lookup_revalidate() does no caching
> (i.e. an otw lookup is issued on every call) the
> ESTALEs still occurred.
> 
> Then I turned my attention to __nfs_refresh_inode() and
> had it used ctime in its calculations of what is
> and is not valid... This did work, but it cause a significant
> amount of extra otw traffic (using the cthon test suite) for
> the non error cases. The one thing good about this patch (imho)
> is the extra lookups only occur after an error that generally
> does not happen...
> 
> Comments would be appreciated, especially about how
> I'm reinstantiating the dentry....

There are several problems here, but the main one is that you have no
guarantees that you are the exclusive user of that dentry.

This again means that people who think they have open files on the "old"
inode may suddenly find their program Oopsing or corrupting the new
file. Ditto for all those shrink_dcache_*() which are likely to Oops.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
