From: Jean-Eric Cuendet <Jean-Eric.Cuendet@linkvest.com>
Subject: Re: rpc.mountd + rpc.nfsd
Date: Tue, 03 Sep 2002 08:56:16 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D745D10.4040409@linkvest.com>
References: <3D7363A7.8090906@linkvest.com> <15732.7907.19389.156631@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

> The serve different protocols (MOUNTD and NFS).  Also mountd runs
OK.

> entirely in user space, nfsd runs entirely in kernel space.  It really
> makes sense for them to be separate.

In fact, I thought of a completely userspace daemon. I took 
nfs-server-userspace-2.2b47 from the net and wondered why there was 2 
daemons while one is IMHO enough.
So, separating things between things that relates is sometimes good, but 
sometimes, it add complexity.
Any comment? Why 2 daemons in userspace. And the 2 run as root (I think...)

-jec



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
