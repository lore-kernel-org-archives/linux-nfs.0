From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: rpc.mountd + rpc.nfsd
Date: 03 Sep 2002 19:01:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8z2j80sf.fsf@charged.uio.no>
References: <3D7363A7.8090906@linkvest.com>
	<15732.7907.19389.156631@notabene.cse.unsw.edu.au>
	<3D745D10.4040409@linkvest.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Jean-Eric Cuendet <Jean-Eric.Cuendet@linkvest.com>
In-Reply-To: <3D745D10.4040409@linkvest.com>
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

>>>>> " " == Jean-Eric Cuendet <Jean-Eric.Cuendet@linkvest.com> writes:

    >> The serve different protocols (MOUNTD and NFS).  Also mountd
    >> runs
     > OK.

    >> entirely in user space, nfsd runs entirely in kernel space.  It
    >> really makes sense for them to be separate.

     > In fact, I thought of a completely userspace daemon. I took
     > nfs-server-userspace-2.2b47 from the net and wondered why there
     > was 2 daemons while one is IMHO enough.

IIRC, this was done in order to allow people to do wierd and wonderful
things. For instance, you could supposedly run the mountd daemon on
one machine, and nfsd on another. We actually have support for this in
the client by way of the option "mounthost=" in the standard mount
program.

I've never heard of anybody actually using that particular feature
though.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
