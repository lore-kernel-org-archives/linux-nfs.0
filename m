From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: open O_EXCL works?
Date: Mon, 14 Mar 2005 08:18:50 -0300
Message-ID: <20050314080517.BD8F.BRANDEN@terra.com.br>
References: <20050313141203.1044.BRANDEN@terra.com.br> <1110739478.10684.42.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAnb3-0006Xw-Bo
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 03:18:53 -0800
Received: from linares.terra.com.br ([200.154.55.228])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DAnb2-0003vd-GD
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 03:18:53 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110739478.10684.42.camel@lade.trondhjem.org>
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


Hi, Trond.

Thank you very much for your very prompt answer.

I would like to get some more advice, since I will need locks in my
application and I'm wondering what will be the best way to implement it,
regarding NFS.

I found this post where you state that the best for locking is a hard
link:
http://marc.theaimsgroup.com/?l=linux-nfs&m=87941837303944&w=2

But the fact is that I need my locks to have a timestamp, so that other
processes can detect that another process created a lock and died before
removing it (in that case I can invalidate all my data).

The problem is that by using hard links, I would have to create a new
file and then create a hard link to this file with the lock file name,
that would be a little more expensive on the NFS side than I'm expecting
to.

I had two other ideas: symlink and mkdir.

However, I made some tcpdumps, and I found out that almost all
operations make a "lookup" before making the operation itself, and if
the file/directory already exists, it skips the main RPC call
(link/symlink/mkdir). The tcpdumps are at the end of the post.

My question is to know what would happen if:
a) at the time the "lookup" call is made, the hardlink/symlink/directory
does not exist yet, so that I can go to the next call;
b) when I call the main function (link/symlink/mkdir), the
hardlink/symlink/directory was already created by another process (maybe
on another host).

What I mean is, apparently (to me at least) there's a race condition
there, that can only be circumvented if mkdir is using the error return
from the mkdir RPC call besides the result of the lookup. Is that the
case?

What I mean is, if I have processes using mkdir to create a lock
directory, can I be sure that no two processes will believe they created
the directory at the same time?

Thanks a lot,
Filipe



* Sun, 13 Mar 2005 13:44:38 -0500, Trond Myklebust <trond.myklebust@fys.uio.no>:
> 2.4.x kernels do not implement O_EXCL opens in NFS due to VFS
> limitations. In 2.6.x we fixed the VFS limitations by adding "intents"
> and so those kernels implement O_EXCL correctly for both NFSv3 and
> NFSv4.
> 
> Cheers,
>   Trond
> 
> -- 
> Trond Myklebust <trond.myklebust@fys.uio.no>


Hardlink:

[popmgr@marova mail7n03-01]$ ln branden.txt teste.txt

07:55:50.749005 10.10.105.244.1636967181 > 10.10.4.7.2049: 136 lookup fh Unknown/1 "teste.txt" (DF)
07:55:50.749219 10.10.105.244.1653744397 > 10.10.4.7.2049: 136 lookup fh Unknown/1 "branden.txt" (DF)
07:55:50.749435 10.10.105.244.1670521613 > 10.10.4.7.2049: 172 link fh Unknown/1 -> fh Unknown/1 "teste.txt" (DF)

[popmgr@marova mail7n03-01]$ ln branden.txt teste.txt
ln: `teste.txt': File exists

07:56:28.974885 10.10.105.244.244720397 > 10.10.4.7.2049: 136 lookup fh Unknown/1 "teste.txt" (DF)
07:56:28.975094 10.10.105.244.261497613 > 10.10.4.7.2049: 136 lookup fh Unknown/1 "branden.txt" (DF)



Symlink:

[popmgr@marova mail7n03-01]$ ln -s branden.txt teste.txt

07:58:18.621391 10.10.105.244.2309366541 > 10.10.4.7.2049: 136 lookup fh Unknown/1 "teste.txt" (DF)
07:58:18.621587 10.10.105.244.2326143757 > 10.10.4.7.2049: 180 symlink fh Unknown/1 "teste.txt" ->"branden.txt" (DF)

[popmgr@marova mail7n03-01]$ ln -s branden.txt teste.txt
ln: `teste.txt': File exists

07:58:20.530707 10.10.105.244.3819315981 > 10.10.4.7.2049: 136 lookup fh Unknown/1 "teste.txt" (DF)
07:58:20.530906 10.10.105.244.3836093197 > 10.10.4.7.2049: 120 readlink fh Unknown/1 (DF)
07:58:20.531040 10.10.105.244.3852870413 > 10.10.4.7.2049: 136 lookup fh Unknown/1 "branden.txt" (DF)



Mkdir:

[popmgr@marova mail7n03-01]$ mkdir teste.dir

07:59:54.027575 10.10.105.244.4240122637 > 10.10.4.7.2049: 136 lookup fh Unknown/1 "teste.dir" (DF)
07:59:54.027798 10.10.105.244.4256899853 > 10.10.4.7.2049: 164 mkdir fh Unknown/1 "teste.dir" (DF)

[popmgr@marova mail7n03-01]$ mkdir teste.dir
mkdir: cannot create directory `teste.dir': File exists

07:59:56.316678 10.10.105.244.96215821 > 10.10.4.7.2049: 136 lookup fh Unknown/1 "teste.dir" (DF)




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
