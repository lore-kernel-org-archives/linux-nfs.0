From: "Marco Schwarz" <marco.schwarz@gmx.net>
Subject: Re: do_vfs_lock Messages
Date: Thu, 09 Nov 2006 10:39:06 +0100
Message-ID: <20061109093906.290540@gmx.net>
References: <20061108144900.241780@gmx.net>
	<1163007231.5712.42.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gi6NO-0004MQ-A2
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 01:39:14 -0800
Received: from mail.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Gi6NO-00030N-0I
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 01:39:15 -0800
In-Reply-To: <1163007231.5712.42.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

> On Wed, 2006-11-08 at 15:49 +0100, Marco Schwarz wrote:
> > Hi,
> > 
> > I am getting A LOT of messages like
> > 
> > Nov  8 15:34:56 linux kernel: do_vfs_lock: VFS is out of sync with lock
> manager!
> > Nov  8 15:35:06 linux last message repeated 156 times
> > 
> > on a discless client system (root on NFS) with Kernel 2.6.18
> > 
> > Is this critical ? If not, can I supress it somehow ? It doesnt happen
> with the same server and my older clients (running 2.4.something).
> 
> It isn't critical. Usually it just means that someone is interrupting
> NFS lock calls. You can suppress it by changing the 'console_loglevel'
> field in /proc/sys/kernel/printk. Use something like
> 
> echo "3       3       1       7" > /proc/sys/kernel/printk
> 
> Cheers,
>   Trond

I tried to mount my nfs root with NOLOCK, shouldnt this also make those messages disappear ?

 host btest.fds{
  hardware ethernet 00:17:31:37:A9:CF;
  fixed-address 192.168.4.39;
  filename "/tftpboot/pxelinux.0";
  option root-path "/netclients/192.168.4.39_sles9,nolock,rsize=4096,wsize=4096";
 }

It doesnt look like anything changed with NOLOCK, still lots of do_vfs_lock
while booting up ...

Best regards,
Marco 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
