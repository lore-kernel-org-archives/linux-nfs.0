From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS over localhost?
Date: Mon, 05 Dec 2005 08:13:39 -0500
Message-ID: <1133788419.8027.24.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0512050921200.18221-100000@lothlorien.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EjGAO-00033v-U3
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 05:14:04 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EjGAJ-0002lt-Qc
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 05:14:04 -0800
To: Helge Bahmann <hcb@chaoticmind.net>
In-Reply-To: <Pine.LNX.4.44.0512050921200.18221-100000@lothlorien.local>
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

On Mon, 2005-12-05 at 09:37 +0100, Helge Bahmann wrote:

> Symptoms: Under heavy write load ("dd if=/dev/zero of=/import/x") both NFS
> client and NFS server deadlock reproducibly, various kernels 2.6.8 -
> 2.6.15-rc4 affected, both SMP and non-SMP. All accesses to "/import" hang
> indefinitely, sometimes also the mount-point "/export" becomes unusable;
> both reiserfs and ext3 as back-end filesystems are affected. This
> situation happens as the "free" memory (as reported by vmstat)
> approaches zero, so it may possibly be an out-of-memory-thing.
> 
> Question(s): Is this kind of deadlock "supposed" to happen? I mean, there
> is no purpose in using NFS in this kind of way (except for configuration
> testing), so I can imagine no one bothers to clean up the interaction
> between NFS client and server in this scenario. However I am slightly
> concerned that a similiar scenario might be possible with our "real" NFS
> server, as it can receive data faster over the network than it can write
> out to the disks. Is this possible?

No, that kind of deadlock is not _supposed_ to happen, but it is very
hard to avoid. Doing loopback mounts will always confuse the VM.
The problem is that the client side can only deal with memory pressure
by writing out pages and then sending them to the server. Since the
server in this case is itself, that therefore actually increases the
memory pressure.
A setup in which client and server are not the same should be a lot more
stable, but there are scenarios where deadlocks can occur there too.

Note that 2.6.15-rc5 includes a fix that should help with one known
client-side out-of-memory scenario, but since that is more related to
shared mmap(), I doubt it will help you here.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
