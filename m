From: pwitting@Cyveillance.com
Subject: Re: Corrupt Data when using NFS on Linux
Date: Tue, 29 Oct 2002 10:09:42 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D38AFB3080F3D311807300B0D0203E53033A92EA@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.cyveillance.com ([63.100.163.104] helo=mercury.cyveillance.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186Y0a-00051x-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 07:10:20 -0800
To: nfs@lists.sourceforge.net
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

> -----Original Message-----
> Subject: Re: [NFS] Corrupt Data when using NFS on Linux
> From: Trond Myklebust <trond.myklebust@fys.uio.no>
> 
> >>>>> " " == Alan Witz <awitz@magstarinc.com> writes:
> 
>      >           *7.10. File Corruption When Using Multiple Clients*
> 
>      >      If a file has been modified within one second of its
>      >      previous modification and left the same size, it will
>      >      continue to generate the same inode number. Because of
>      >      this, constant reads and writes to a file by multiple
>      >      clients may cause file corruption. Fixing this bug
>      >      requires changes deep within the filesystem layer, and
>      >      therefore it is a 2.5 item.
> 
> That passage looks pretty confused to me. The inode number is indeed
> irrelevant here.
> 
> The reason for the problem is that NFS uses the file's mtime and size
> in order to determine whether or not another NFS client has written to
> the file since it was last opened.
> 
> For most NFS servers, the mtime has a resolution of 1 microsecond or
> better. Under Linux, however, the mtime has a resolution of 1
> second. Hence if your *server* is a Linux machine, then a change by
> another client that occurs within 1 second of your last change might
> not cause mtime to be updated. Unless this second change also causes
> the file size to change, it will appear to your client as if nobody
> else has touched the file, and file corruption may follow due to the
> fact that the 2 clients' file caches disagree.
> 
> Cheers,
>   Trond

I'm curious now. Is this issue really in the linux kernel or is this
actually a Filesystem issue? It would seem to be a filesystem issue,
specifically how the FS chose to store the mtime, which could allow a
different FS (say, a non-linux fs such as jfs or xfs) to solve the problem.

Of course, given the "file centric" design of linux/unix I could see it
being a kernel issue; but wonder how quickly they'll move to resolve the
issue given the forward/backward compatibility issues (but then, they seemed
to have migrated ext2 from 32 to 64 bits pretty cleanly, so maybe)

Thanks


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
