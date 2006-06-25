From: Ian Kent <raven@themaw.net>
Subject: Re: Number of nfsd processes?
Date: Sun, 25 Jun 2006 20:44:56 +0800 (WST)
Message-ID: <Pine.LNX.4.64.0606252039300.4866@raven.themaw.net>
References: <40b437200606241759u3ec0ccd7q578c1ac476d498d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FuTzW-0006fX-TP
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 05:45:30 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1FuTzU-0004Ga-Fa
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 05:45:31 -0700
To: Simon Matthews <simon.d.matthews+nfs@gmail.com>
In-Reply-To: <40b437200606241759u3ec0ccd7q578c1ac476d498d9@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sat, 24 Jun 2006, Simon Matthews wrote:

> I am running servers based on recent 2.6.x kernels.
> 
> I see "server timeout" messages from client machines running 2.4.x
> kernels (typically RedHat kernels). I have tried increasing the number
> of nfsd processes, but I seem to have got it up to absurd numbers (64
> processes).

Absurd, don't think so.
I'd say for many "normal" NFS server environments this is likely a good 
starting point, certainly not the high end.

Last place I worked we started by setting the number of threads on NFS 
servers (Solaris) to 128 or 256 depending on expected work load, 128 for 
the lightly loaded servers. 

Ian

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
