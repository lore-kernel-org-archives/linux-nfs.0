From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 13:49:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1082742547.2617.86.camel@lade.trondhjem.org>
References: <40892507.2030004@RedHat.com>
	 <1082730973.2617.23.camel@lade.trondhjem.org> <40893DEF.3010506@RedHat.com>
	 <1082737270.2617.80.camel@lade.trondhjem.org> <40895096.9020507@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH4nX-0003DC-MT
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 10:49:11 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BH4nX-0008Sd-AO
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 10:49:11 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40895096.9020507@RedHat.com>
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

On Fri, 2004-04-23 at 13:21, Steve Dickson wrote:

> Question: if (atomic_read(&dentry->d_count) < 2)
> can I assume that the current process is the only one
> attached to the dentry and it would be safe reinstantiate
> the dentry?

You can if and only if

  - The dentry is unhashed, and you are holding the semaphore dir->i_sem
on the parent directory.
OR
  - You are holding the spin lock dcache_lock.

Both of these two methods will prevent the VFS from looking the dentry
up.

Note: on 2.6.x, the second condition needs to be modified a bit: you
probably need to hold dentry->d_lock too since the 2.6.x version of
d_lookup() is by and large lockless...

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
