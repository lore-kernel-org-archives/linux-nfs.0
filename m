From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: open O_EXCL works?
Date: Tue, 22 Mar 2005 10:28:28 -0300
Message-ID: <20050322101843.BE94.BRANDEN@terra.com.br>
References: <20050322073459.BE83.BRANDEN@terra.com.br> <1111494435.21559.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDjQ8-0002OA-Rw
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 05:27:44 -0800
Received: from linares.terra.com.br ([200.154.55.228])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDjPo-0002kh-SV
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 05:27:44 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1111494435.21559.20.camel@lade.trondhjem.org>
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


Hi again,

* Tue, 22 Mar 2005 07:27:15 -0500, Trond Myklebust <trond.myklebust@fys.uio.no>:
> > Isn't there a safe and cheap way to use a lock file that works on NFSv3
> > on a 2.4.9 kernel?
> 
> The best way to ensure cache consistency is to put a posix (i.e.
> fcntl()) lock on the file after you have created the lock file. Doing so
> will flush the stale caches.

Let me see if I understand: the lock (with the hardlink) is working fine,
my problem is actually with the position where to append, is that it?
Somehow, the information of the size of the file (that is where the append
will write) is being cached in my clients, and if two clients append at
the same time, the cache may cause them to overwrite each other, right?

If so, you suggest me to use fcntl on the file where I'm writing before
the write operation, right? This would be the code:


  f = open("myfile", O_CREAT|O_WRONLY|O_APPEND)

  [repeat the loop below for the data]
    hardlink("myfile", "myfile.lock")
    -> if it fails, invalidate information
    fcntl(f, F_SETLK, F_WRLCK)
    -> if it fails, invalidate information
    write(f, "mydata", sizeof(mydata))
    fcntl(f, F_SETLK, F_UNLCK)
    unlink("myfile.lock")
  [end loop]

  close(f)


Would this work? Also, using fcntl(F_SETLK) implies mounting filesystems
without the "nolock" option (that is what I'm using now), and implies
running lockd, right? Also, wouldn't I have problems if some process
dies between locking and unlocking with fcntl?

Would change the position of "open" and "close" to inside the hardlink
lock solve the problem? What I mean is, would this code work as I expect,
with appends being atomic between different clients?


  [repeat the loop below for the data]
    hardlink("myfile", "myfile.lock")
    -> if it fails, invalidate information
    f = open("myfile", O_CREAT|O_WRONLY|O_APPEND)
    write(f, "mydata", sizeof(mydata))
    close(f)
    unlink("myfile.lock")
  [end loop]


Thanks a lot,
Filipe



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
