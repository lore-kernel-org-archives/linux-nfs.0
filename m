From: Jakob Oestergaard <jakob@unthought.net>
Subject: Re: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 18:05:21 +0200
Message-ID: <20060330160521.GC9811@unthought.net>
References: <Pine.LNX.4.64.0603300813270.18696@p34> <1143728720.8074.41.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603300929340.18696@p34> <1143729766.8074.49.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603300949000.18696@p34> <1143731364.8074.53.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603301011160.18696@p34> <20060330153128.GB9811@unthought.net> <Pine.LNX.4.61.0603301053030.738@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Piszcz <jpiszcz@lucidpixels.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOzeN-0002hc-6W
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 08:05:31 -0800
Received: from unthought.net ([212.97.129.88])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FOzeI-0008Cf-Qr
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 08:05:28 -0800
To: "linux-os (Dick Johnson)" <linux-os@analogic.com>
In-Reply-To: <Pine.LNX.4.61.0603301053030.738@chaos.analogic.com>
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

On Thu, Mar 30, 2006 at 10:58:08AM -0500, linux-os (Dick Johnson) wrote:
...
> This is my /etc/exports and it works fine with linux-2.6.15.4.
> All the host names are local, inside the firewall, and need to
> be looked-up over a W$<crap> name-server.
> 
> #
> /rmtboot/LinuxRoot	*(ro,async)
> /root/Scanner	*(ro,no_root_squash,sync)
> /tmp		*(rw,no_root_squash,sync)
> /usr/src	quark(rw,no_root_squash,sync)
> /usr/lib	quark(rw,no_root_squash,sync)
...

Well lucky you  :)

I'm not saying it can't work. I'm just saying I've spent too much time
finding out the hard way that it does not necessarily work  :)

-- 

 / jakob



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
