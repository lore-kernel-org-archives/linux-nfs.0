From: Pavel Machek <pavel@ucw.cz>
Subject: Re: NFS on loopback locks up entire system(2.6.23-rc6)?
Date: Sat, 6 Oct 2007 07:35:35 +0000
Message-ID: <20071006073534.GA4727@ucw.cz>
References: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
	<1190335423.6763.180.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ie4CV-0005WZ-Af
	for nfs@lists.sourceforge.net; Sat, 06 Oct 2007 00:35:51 -0700
Received: from gprs189-60.eurotel.cz ([160.218.189.60] helo=spitz.ucw.cz)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ie4CX-0004d8-HF
	for nfs@lists.sourceforge.net; Sat, 06 Oct 2007 00:35:56 -0700
In-Reply-To: <1190335423.6763.180.camel@heimdal.trondhjem.org>
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

Hi!

> > I am testing NFS on loopback locks up entire system with 2.6.23-rc6 kernel.
> > 
> > I have mounted a local ext3 partition using loopback NFS (version 3)
> > and started my test program. The test program forks 20 threads
> > allocates 10MB for each thread, writes & reads a file on the loopback
> > NFS mount. After running for about 5 min, I cannot even login to the
> > machine. Commands like ps etc, hang in a live session.
> > 
> > The machine is a DELL 1950 with 4Gig of RAM, so there is plenty of RAM
> > & CPU to play around and no other io/heavy processes are running on
> > the system.
...
> > Any ideas what could potentially trigger this?
> 
> This is pretty much expected: the NFS server is trying to allocate
> memory. The VM then tries to satisfy that demand by freeing up resources
> from the NFS client by telling the client to write out cached pages. The
> client again is in a congested state in which it is waiting on the NFS
> server to finish writing out what it already sent.
> 	Quod Erat Deadlocked...

Could we add nice warning to documentation? Or make kernel
printk(ALERT) when user tries to mount 127.0.0.1 (ok, that may not be
completely foolproof). Or make server refuse connections from
localhost and syslog loudly?
							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
