From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: 2.4.19 hang (was unlink perf pb !)
Date: Tue, 20 Aug 2002 00:40:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15713.29660.340684.546317@charged.uio.no>
References: <8D7D56C6ED3DD411998D009027DC685E0874E233@srv-grp-s1.segin.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: 'Trond Myklebust' <trond.myklebust@fys.uio.no>,
    "'Lever, Charles'" <Charles.Lever@netapp.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17gvCS-0001xf-00
	for <nfs@lists.sourceforge.net>; Mon, 19 Aug 2002 15:40:40 -0700
To: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
In-Reply-To: <8D7D56C6ED3DD411998D009027DC685E0874E233@srv-grp-s1.segin.com>
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

>>>>> " " == Brasseur Valéry <Valery.Brasseur@atosorigin.com> writes:

     > more on my problem ...
     > * it seems that when using tcp mount the hang appears more
     >   often and more
     > quickly !
     > * on stock 2.4.19 which I have is a limited perf but it works
     > * on 2.4.19 + nfs patches I have limited perf + hang !

     > I said I have limited perf because the NetApp filer I use as
     > server is a 880 which is given for more than 15000 nfs/ops and
     > with my Linux box I can't do more than 2/3000 ops when I am the
     > only client !

     > how can I track this down ?

Unless you are using some form of NAT (a.k.a. masquerading) it sounds
rather like you have some serious networking problems. Certainly I
have never heard of anybody having problems with hangs on both UDP
*and* TCP mounts - the latter in particular was designed to work
around network congestion problems.

Have you therefore tried things like swapping out the networking card
for another (preferably of a different make and different Linux
driver), and ditto for any switches/HUBs?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
