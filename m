From: Steve Wampler <swampler@noao.edu>
Subject: Re: What might cause:  "NFS: Buggy server - nlink == 0!"
	message?
Date: Wed, 21 Jan 2004 08:22:53 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1074698573.18082.39.camel@weaver.tuc.noao.edu>
References: <1074293142.11334.63.camel@weaver.tuc.noao.edu>
Reply-To: swampler@noao.edu
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjKCB-0004eb-Oh
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 07:23:07 -0800
Received: from dns.noao.edu ([140.252.1.54] helo=noao.edu)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjKCB-0006fm-Dr
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 07:23:07 -0800
To: Linux NFS List <nfs@lists.sourceforge.net>
In-Reply-To: <1074293142.11334.63.camel@weaver.tuc.noao.edu>
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

On Fri, 2004-01-16 at 15:45, Steve Wampler wrote:
> We've been noticing that some of our NFS clients aren't catching
> changes to NFS-accessed files.  This last time, dmesg
> on the client reported:
> 
>    NFS: Buggy server - nlink == 0!
>    __nfs_fhget: iget failed
> 
> What might cause this?  What's the best fix?
> 
> The NFS server is a Red Hat system:
> 
>    ->uname -a
>    Linux friar.tuc.noao.edu 2.4.18-24.8.0smp #1 SMP Fri Jan 31 07:12:12
> EST 2003 i686 athlon i386 GNU/Linux
>    ->rpm -qa | grep nfs
>    nfs-utils-1.0.1-2

As an update:

I've updated all the machines clients and server to
     nfs-utils-1.0.5-2.

[Server and most clients are dual-Athlon 1800+ machines
with 1.5GB Ram each (identical boxes).  Network is a switched
gigabit ethernet.

A few client machines connect via 100bT ethernet and vary
from SUN Solaris boxes to other dual-Athlons, but rarely
use the NFS mount 'in anger' - unlike the gigabit machines].

I've bumped the number of nfsd daemons on the server to 30,
in part because showmount shows 30 nfs mount points (I'm
not convinced that's true, incidently, as several of the
machines appear both under their IP-name and under
their IP-address).

The above message still appears from time to time and
files don't always appear on some clients until an unmount/mount
cycle of the NFS partitions.  This is a problem, of course.

Any ideas?  Is the 2.4.18smp kernel flakey with respect to
NFS?

Thanks!
Steve
-- 
Steve Wampler -- swampler@noao.edu
The gods that smiled on your birth are now laughing out loud.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
