From: trond.myklebust@fys.uio.no
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Mon, 1 Mar 2004 19:58:08 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35345.207.214.87.84.1078167488.squirrel@webmail.uio.no>
References: <Pine.LNX.4.44.0403011907010.10276-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Shantanu Goel" <Shantanu.Goel@lehman.com>,
     "Shantanu Goel" <sgoel01@yahoo.com>,
     "Charles Lever" <Charles.Lever@netapp.com>,
     "Olaf Kirch" <okir@suse.de>,"Greg Banks" <gnb@melbourne.sgi.com>,
     nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Axst0-0006bT-Gj
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 11:15:30 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxsXL-00025R-MU
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 10:53:07 -0800
To: "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0403011907010.10276-100000@kenzo.iwr.uni-heidelberg.de>
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

På må , 01/03/2004 klokka 10:18, skreiv Bogdan Costescu:
> On Mon, 1 Mar 2004, Shantanu Goel wrote:
> But how is the kernel to know which process is the "bad" one which 
should be punished ? Maybe this process that writes now lots does so 
because it's just about to finish (or dumping core :-)) so it's more 
advantageous to give it a bit of priority because it won't bother 
anymore afterwards. On the other hand, if it's just writting and 
writting and not going away soon, it should be punished. So how can  the
kernel make the difference between these 2 situations ?

I'm currently working on a scheme for throttling processes that keep on
scheduling new writes while the VM is trying to free up memory.


> If the second process is writting to the same file, then I think that 
this behaviour is actually wanted (of course, without locking, the  data
will be messsed up...).

Writes always take the i_sem semaphore, so no problems with mess ups. I've
already got patches for improving the caching in the above case (we
basically get rid of nfs_strategy() and leave the job of deciding when to
schedule the writes to pdflush).

> If they are writting to different files, probably it makes sense to 
make sure that both files advance a bit, so queueing based on inode 
might also make sense.

Agreed.

> Queueing based on PID is probably bad also from another point of view: 
a process can have more than one file open at the same time and can do 
various operations on them. If it writes a lot to one file and then 
wants to read a small piece from another file, should it have to wait 
until the writes are done to perform the read ?

In practice you can have several processes competing for the same reads,
writes etc. I'd prefer to treat reads and writes as "belonging" to the
mapping rather than to any one process...

For synchronous operations, however, a pid (or equivalent) is fine...

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
