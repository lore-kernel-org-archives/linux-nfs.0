From: Neil Brown <neilb@suse.de>
Subject: Re: Manpage inconsistency
Date: Mon, 5 Feb 2007 10:02:42 +1100
Message-ID: <17862.26130.704626.300662@notabene.brown>
References: <20070104131046.GA30920@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDqO8-0001zN-VM
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 15:03:13 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDqO9-0008L1-BJ
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 15:03:14 -0800
In-Reply-To: message from Steinar H. Gunderson on Thursday January 4
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

On Thursday January 4, sgunderson@bigfoot.com wrote:
> Hi,
> 
> It seems like the man page for rpc.statd claims that it lives in /sbin.
> However, make install puts it in /usr/sbin. Which should be corrected? :-)
> 
> (It should be mentioned that in Debian, we move both rpc.statd, rpc.lockd and
> showmount into /sbin, since we might need them at boot time and patch the
> manpages appropriately, but at least upstream should be consistent with
> itself.)

I've remove the path from the man page so it doesn't say "/sbin" or
"/usr/sbin".

But I'm surprised you want it in /sbin.  I would mount '/usr' with '-o nolocks'
After all, you cannot run statd until /var is mounted.....

But whatever...

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
