From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale handle error on RHEL4 (2.6.9-22.ELsmp)
Date: Thu, 16 Feb 2006 10:27:33 -0500
Message-ID: <1140103653.8891.29.camel@lade.trondhjem.org>
References: <20060216151417.42042.qmail@web51611.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9l31-0004Zf-Sl
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 07:27:59 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9l2x-0000h0-A2
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 07:27:59 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060216151417.42042.qmail@web51611.mail.yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Thu, 2006-02-16 at 07:14 -0800, mehta kiran wrote:
> Hi,
>     When nfs(v4) server fails over from one system to 
>     other it gets stale handle error.
>     All systems have RHEL4 installed (same kernel)
>     uname -a  = 2.6.9-22.ELsmp #1 SMP 
>     
> 
>     Details :
> 
> [root@vcslinux118 bin]# mount
> <---snip>
> sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
> nfsd on /proc/fs/nfsd type nfsd (rw)
> /dev/sdi2 on /dir2 type ext3 (rw)
> /dev/sdi1 on /dir1 type ext3 (rw)
> /dir2 on /export/exp2 type bind (rw,bind)
> /dir1 on /export/exp1 type bind (rw,bind)
> </---snip>
> 
> [root@vcslinux118 bin]# exportfs -v
> /export/exp1   
> <world>(rw,wdelay,nohide,no_root_squash)
> /export/exp2   
> <world>(rw,wdelay,nohide,no_root_squash)
> /export        
> <world>(rw,wdelay,nohide,no_root_squash,fsid=0)
> [root@vcslinux118 bin]# uname -a
> Linux vcslinux118.vxindia.veritas.com 2.6.9-22.ELsmp
> #1 SMP Mon Sep 19 18:00:54 EDT 2005 x86_64 x86_64
> x86_64 GNU/Linux
> 
> I have mounted this on client as 
> #mount -t nfs4 10.212.102.70:/ /kiran
> 
> After failover i get stale handle error on client.
> Is this a known issue ?

It is expected, yes. Your failover system has to be a precise copy of
the original filesystem. If the inode number differs for a given file or
directory, then the filehandles will differ on the original system and
the failover system, and so you will get ESTALE errors.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
