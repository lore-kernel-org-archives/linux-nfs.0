From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: redhat 2.4.18-5 client huge slowdownB
Date: 10 Jul 2002 22:19:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs4rf7gwtl.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0207101440370.7151-100000@duran.unl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SNwZ-0006kX-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 13:20:11 -0700
Received: from charged.uio.no ([129.240.86.49])
	by mons.uio.no with esmtp (Exim 2.12 #7)
	id 17SNwR-00041Z-00
	for nfs@lists.sourceforge.net; Wed, 10 Jul 2002 22:20:03 +0200
Received: from trondmy by charged.uio.no with local (Exim 2.12 #1)
	id 17SNvy-00087J-00
	for nfs@lists.sourceforge.net; Wed, 10 Jul 2002 22:19:34 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0207101440370.7151-100000@duran.unl.edu>
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

>>>>> " " == Rex Dieter <rdieter@math.unl.edu> writes:

     > Raphael Clifford wrote:
    >> I was wondering if everyone else is experiencing huge nfs write
    >> slowdowns using redhat kernel 2.4.18-5 (as opposed to
    >> 2.4.18-4).  I am

     > Yes, I've also experienced a huge nfs client slowdown (~50k/sec
     > writes) on 'sync' nfs mounts with the 2.4.18-5 kernel... See me
     > bugzilla report:
     > http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=67199 and a
     > similar report as well:
     > http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=67461

     > The only way I found to get any sort of respectable performance
     > out of 2.4.18-5 was to mount 'async'. *ack*

For 2.4.18-5 RedHat appears to have decided to set the default r/wsize
to 4k. To override, just specify larger values for rsize and wsize on
the mount option. Use something like

mount -t nfs -ohard,intr,rsize=32768,wsize=32768 nonlinux_server:/foo /bar

or

mount -t nfs -ohard,intr,rsize=8192,wsize=8192 linux_server:/foo /bar

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Two, two, TWO treats in one.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
