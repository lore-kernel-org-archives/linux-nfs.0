From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Mon, 1 Mar 2004 19:18:14 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0403011907010.10276-100000@kenzo.iwr.uni-heidelberg.de>
References: <40437AE4.4030407@lehman.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no, Shantanu Goel <sgoel01@yahoo.com>,
        Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>,
        Charles Lever <Charles.Lever@netapp.com>, Olaf Kirch <okir@suse.de>,
        Greg Banks <gnb@melbourne.sgi.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Axs4V-0003QP-10
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 10:23:19 -0800
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Axs0D-00079j-R2
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 10:18:54 -0800
To: Shantanu Goel <Shantanu.Goel@lehman.com>
In-Reply-To: <40437AE4.4030407@lehman.com>
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

On Mon, 1 Mar 2004, Shantanu Goel wrote:

> It won't fix the underlying issue that a single heavy writer will
> block other async writes for a looong time.

But how is the kernel to know which process is the "bad" one which 
should be punished ? Maybe this process that writes now lots does so 
because it's just about to finish (or dumping core :-)) so it's more 
advantageous to give it a bit of priority because it won't bother 
anymore afterwards. On the other hand, if it's just writting and 
writting and not going away soon, it should be punished. So how can 
the kernel make the difference between these 2 situations ?

> Another process comes along and writes 128K then closes the file.  
> Before the close, it will call nfs_strategy() which will queue async
> writes after all the ones from dd.  So, effectively, how quickly dd
> completes will determine how quickly this process can return from
> close.

If the second process is writting to the same file, then I think that 
this behaviour is actually wanted (of course, without locking, the 
data will be messsed up...).
If they are writting to different files, probably it makes sense to 
make sure that both files advance a bit, so queueing based on inode 
might also make sense.

Queueing based on PID is probably bad also from another point of view: 
a process can have more than one file open at the same time and can do 
various operations on them. If it writes a lot to one file and then 
wants to read a small piece from another file, should it have to wait 
until the writes are done to perform the read ?

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
