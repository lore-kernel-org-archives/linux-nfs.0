From: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
Subject: Re: Clients not displaying NFS quotas
Date: Mon, 7 May 2007 09:50:23 +0930 (CST)
Message-ID: <200705070020.l470KNxD004058@turbo.physics.adelaide.edu.au>
References: <1178496403.6493.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
To: trond.myklebust@fys.uio.no (Trond Myklebust)
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hkqy0-0003dl-HY
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:20:40 -0700
Received: from adelphi.physics.adelaide.edu.au ([129.127.102.1])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hkqy1-0008Eg-Jk
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:20:43 -0700
In-Reply-To: <1178496403.6493.18.camel@heimdal.trondhjem.org> from "Trond
	Myklebust" at May 06, 2007 08:06:43 PM
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

> On Mon, 2007-05-07 at 08:57 +0930, Jonathan Woithe wrote:
> > > On Thu, 2007-05-03 at 11:43 +0930, Jonathan Woithe wrote:
> > > > We have a Slackware 9.1 box (with numerous software upgrades) exporting a
> > > > directory to various NFS clients.  While running a 2.4.x kernel this all
> > > > worked fine - users on clients could use "quota" to display their quota
> > > > information.  When the system was moved to a 2.6.19.2 kernel a few months
> > > > ago the clients could no longer display quota information.  The server
> > > > still knew and enforced the quotas, it's just that from the client's
> > > > point of view there were no quotas.
> > > > 
> > > > The system is running the following software versions:
> > > > 
> > > >   * kernel 2.6.19.2
> > > >   * nfs-utils 1.0.10
> > > >   * util-linux 2.12
> > > >   * portmap 5.0
> > > > 
> > > > The filesystem concerned is reiserfs3.  The kernel has reiserfs quota
> > > > support enabled.
> > > > 
> > > > The relevant partition is mounted on the server using an fstab entry of
> > > > 
> > > >   /dev/...  /home/foobar  reiserfs  usrquota
> > > > 
> > > > All clients mount the volume via the automounter with the "hard,intr,bg"
> > > > mount options.
> > > > 
> > > > Users cannot log into the NFS server.
> > > > 
> > > > We have clients running various versions of redhat, fedora and slackware
> > > > with different kernels.  In all cases things worked with the 2.4.x
> > > > kernel and don't now.  It therefore seems to be a server-related issue.
> > > > 
> > > > Does anyone have any idea as to why client access to quota information
> > > > isn't working in this scenario?
> > > 
> > > The NFS protocol doesn't support quotas, so those have to be transmitted
> > > using a sideband protocol. Check that you have the 'quotad' daemon
> > > running on your server, and that it is accessible from the clients.
> > 
> > Yes, quotad is running on the server:
> > 
> >   > rpcinfo -p
> >   :
> >   100011    1   udp    998  rquotad
> >   100011    2   udp    998  rquotad
> > 
> > As I mentioned, everything works just fine if a 2.4.x kernel is running,
> > which presumedly clears any access issues (unless of course the 2.6.x kernel
> > is doing something odd).  The moment 2.6.x is booted (where x = 19.2
> > currently) the clients can no longer see quota information.
> > 
> > Is there a way to explicitly test whether clients can in fact connect to
> > rquotad?
> > 
> > I have noticed that rquotad is only listening on UDP, rather than on both
> > TCP and UDP as I think it did under 2.4.x.  Is this likely to be the
> > problem?  If so, what would cause rquotad to do this under 2.6.x given an
> > unchanged configuration from 2.4.x?
> > 
> > Here are the relevant kernel configuration options for the kernel currently
> > running:
> 
> On the client, the kernel isn't at all involved in NFS quotas other than
> for the usual sendmsg()/recvmsg() syscalls as used by the userspace RPC
> library. IOW: all the clever stuff happens in userspace.
> 
> I'd therefore try running 'strace' on the 'quota' command in order to
> figure out what is going wrong.

I tried that earlier but nothing really jumped out at me - it seemed that
the server was being contacted without error.

If you're interested you can download a copy of the strace output from
a representative client from

  http://www.physics.adelaide.edu.au/~jwoithe/q-mercury.strace.bz2

I would have attached it but I suspect it might make the message too big
for the list.

In the meantime I might try comparing the strace from the client (where it
doesn't work) and the server (where it does) and see if anything obvious
jumps out.

Regards
  jonathan

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
