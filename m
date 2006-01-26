From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS dentry caching mechanism
Date: Thu, 26 Jan 2006 18:14:07 -0500
Message-ID: <1138317247.8770.39.camel@lade.trondhjem.org>
References: <OFE1F20AE4.839B09EC-ON87257102.007A50EE-88257102.007C7D01@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2GJy-0000jp-DU
	for nfs@lists.sourceforge.net; Thu, 26 Jan 2006 15:14:30 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F2GJx-0007nN-TP
	for nfs@lists.sourceforge.net; Thu, 26 Jan 2006 15:14:30 -0800
To: uketinen@us.ibm.com
In-Reply-To: <OFE1F20AE4.839B09EC-ON87257102.007A50EE-88257102.007C7D01@us.ibm.com>
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

On Thu, 2006-01-26 at 14:40 -0800, Usha Ketineni wrote:
> 
> 
> 
> We are investigating an issue with the NFS client code in 2.4.21
> kernel:
> 
> To reproduce the issue: 
> 
> (using machine A and machine B, and a file system mounted off an NFS
> server 
> called /home)
> 
> 1) On Machine A: 
> 
> ls home/source 
> ls: /home/source: No such file or directory 
> 
> 2) On machine B: 
> touch /home/source 
> 
> 3) back on machine A: 
> rm /home/source 
> rm: cannot lstat `source': No such file or directory 
> 
> But source *does* exist. 
> 

Why on earth is 'rm' trying to lstat the file? That is both racy and
unnecessary.

> This shows the problem.
> 
> ===
> 
> There are workarounds:
> 
> 1) Mount the file system with acdirmin=0 and acdirmax=0. But this then
> affects 
> all system calls, not just unlink(). And it hurts NFS performance.
> 
> 2) Mount the file system with the noac option, but the same negative
> effect as 
> in #1 applies.
> 
> What happens is this: 
> 
> 0) Let F be a filename on the NFS file system. Initially this file
> does not exist.
> 
> 1) The application on the machine A does a stat() on F. The NFS
> client in the kernel sends a LOOKUP request to the NFS server, which
> obviously returns failure. The stat() fails with ENOENT. OK so far.
> 
> 2) Immediately afterwards (a few seconds max), the application on
> machine B creates the file F. No problems so far.
> 
> 3) When B is done with F, a few seconds later the application on
> machine A does an unlink() on F. Because of the negative dentry
> caching in the Linux kernel, it doesn't even bother to send an NFS
> REMOVE request to the NFS server, as (it thinks) it knows for sure the
> file doesn't exist. It lets the unlink() fail with ENOENT. But the
> file definitely exists. 
> 
> Is there any other solution for this (including moving to a newer
> kernel)? 
> 
I suppose one could add a VFS intent for unlink in order to force
nfs_lookup_revalidate() to drop the negative dentry. We don't do that on
any existing kernels though (particularly not on 2.4 kernels, as they
don't support intents).

However I suspect that most non-linux clients will similarly cache
negative DNLC entries, and be vulnerable to the same problem.

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
