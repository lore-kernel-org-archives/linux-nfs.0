From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: rpc.mountd + rpc.nfsd
Date: Tue, 3 Sep 2002 12:30:59 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15732.7907.19389.156631@notabene.cse.unsw.edu.au>
References: <3D7363A7.8090906@linkvest.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Jean-Eric Cuendet <Jean-Eric.Cuendet@linkvest.com>
In-Reply-To: message from Jean-Eric Cuendet on Monday September 2
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

On Monday September 2, Jean-Eric.Cuendet@linkvest.com wrote:
> Hi,
> Why is there 2 daemons for NFS progs? Is it a necessity or just to
> separate things?
> Would it be possible to have only one nfsd daemon that is rpc.mounts +
> rpc.nfsd + ... ?

The serve different protocols (MOUNTD and NFS).  Also mountd runs
entirely in user space, nfsd runs entirely in kernel space.  It really
makes sense for them to be separate.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
