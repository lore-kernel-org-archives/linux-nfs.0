From: Andrew Ryan <andrewr@nam-shub.com>
Subject: RE: 2.4.20-rc1 NFS/TCP client (still) hangs running
  dbench  2.0
Date: Sat, 02 Nov 2002 08:49:18 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20021102084642.029256d0@pop.sfrn.dnai.com>
References: <6440EA1A6AA1D5118C6900902745938E07D5503C@black.eng.netapp.
 com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from moe.sfrn.dnai.com ([208.59.199.25])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1881Ql-0006sv-00
	for <nfs@lists.sourceforge.net>; Sat, 02 Nov 2002 08:47:27 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>,
   "'trond.myklebust@fys.uio.no'" <trond.myklebust@fys.uio.no>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D5503C@black.eng.netapp.
 com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

At 06:57 AM 11/2/02 -0800, Lever, Charles wrote:
>i suspect andrew is seeing partial transmits -- in 2.4.20-pre, partial
>TCP transmissions are counted as retransmits.  in fact, it looks like the
>patch i sent in august for 2.4.20-pre5 to fix xprt_write_space was never
>applied to 2.4.  trond, can you ping marcelo on this?  it's a pretty
>important performance enhancement that should be in 2.4.20.

It also seems that this patch was never included in Trond's 
linux-2.4.20-NFS_ALL.dif patchset, although I found it in my email (sent 
Aug 30, 2002). I'll test it out this weekend and post with/without results.


> > Note: the TCP timeout + retransmits will (unlike UDP) be of the order
> > of 60 seconds, so if these were real retransmits, you'd be seeing a
> > *very* noticeable slowdown...
>
>except that mount is broken and sets a 6 second TCP retransmission default
>rather than the standard value of 60 seconds.

Is this a big problem? Should we be upgrading/patching mount if we are 
going to use TCP mounts?



thanks,
andrew



-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
