From: James Pearson <james-p@moving-picture.com>
Subject: Re: ANNOUNCE: nfs-utils 1.0.4
Date: Tue, 29 Jul 2003 15:16:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F2681A6.7E33A7E6@moving-picture.com>
References: <1030714170001.24267@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19hVHV-0001PU-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Jul 2003 07:16:49 -0700
To: "Neil F. Brown" <neilb@cse.unsw.edu.au>
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

"Neil F. Brown" wrote:
> 
> 3/ In 2.4 and earlier kernels, the nfs server needed to know about any
>  client that expected to be able to access files via NFS.  This
>  information would be given to the kernel by "mountd" when the client
>  mounted the filesystem, or by "exportfs" at system startup.  exportfs
>  would take information about active clients from /var/lib/nfs/rmtab.
> 
>  This approach is quite fragile as it depends on rmtab being correct
>  which is not always easy, particularly when trying to implement
>  fail-over.  Even when the system is working well, rmtab suffers from
>  getting lots of old entries that never get removed.
> 
>  With 2.6 we have the option of having the kernel tell mountd when it
>  gets a request from an unknown host, and mountd can give appropriate
>  export information to the kernel.  This removes the dependancy on
>  rmtab and means that the kernel only needs to know about currently
>  active clients.
> 
>  To enable this new functionality, you need to:
>    mount -t nfsd nfsd /proc/fs/nfs
> 
>  before running exportfs or mountd.
> 
>  If you are using 2.6.0-testX and exporting files with NFS *please*
>  test this out and let me know of any problems.

I've just been trying out 2.6.0-test2 with nfs-utils 1.0.5 and I've come
across a couple of problems:

When using 'mount -t nfsd nfsd /proc/fs/nfs' on the server, if I now run
'showmount -d server', nothing is returned. If I don't use the 'mount -t
nfsd ...', showmount works as expected.


When starting /etc/init.d/nfs, I get a pause between 'Starting NFS
daemon' and 'Starting NFS mountd' - this turns out to be rpcinfo timing
out i.e.

rpcinfo: RPC: Timed out
program 100003 version 3 is not available

i.e. from '/usr/sbin/rpcinfo -u localhost nfs 3'

and hence rpc.mountd starts with '--no-nfs-version 3'

Once nfsd is up and running, rpcinfo returns the expected result.

Forcing 'MOUNTD_NFS_V3=yes' works fine, and clients can mount using
NFSv3


One thing I would be interested in knowing - how does the server now
'know' about clients that have mounted file systems across server
reboots now that /var/lib/nfs/rmtab is no longer used?

James Pearson


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
