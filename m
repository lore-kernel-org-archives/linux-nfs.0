From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 12:21:10 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1082737270.2617.80.camel@lade.trondhjem.org>
References: <40892507.2030004@RedHat.com>
	 <1082730973.2617.23.camel@lade.trondhjem.org> <40893DEF.3010506@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH3QO-00081s-3c
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 09:21:12 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BH3QN-0005bB-Qh
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 09:21:11 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40893DEF.3010506@RedHat.com>
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

On Fri, 2004-04-23 at 12:01, Steve Dickson wrote:
> >This again means that people who think they have open files on the "old"
> >inode may suddenly find their program Oopsing or corrupting the new
> >file. 
> >
> Again, this new fh is only gotten on getattrs any other ops will still
> fail with ESTALE...

No! That dentry is a shared object, and you may be changing it while
other ops are referencing/using it. There are no locks or any other
mechanisms here that ensure this is not the case.

Even if you do solve the above race, you still have another bug: you are
changing the object that the "struct file" refers to, and hence at best
you are going to cause all the existing open files to start reading
from/writing to the new file (which is a bug!) instead of returning
ESTALE.

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
