From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: do_vfs_lock Messages
Date: Wed, 08 Nov 2006 09:33:51 -0800
Message-ID: <1163007231.5712.42.camel@lade.trondhjem.org>
References: <20061108144900.241780@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhrK1-0008Gd-JL
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 09:34:45 -0800
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhrJv-0002HH-K9
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 09:34:43 -0800
To: Marco Schwarz <marco.schwarz@gmx.net>
In-Reply-To: <20061108144900.241780@gmx.net>
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

On Wed, 2006-11-08 at 15:49 +0100, Marco Schwarz wrote:
> Hi,
> 
> I am getting A LOT of messages like
> 
> Nov  8 15:34:56 linux kernel: do_vfs_lock: VFS is out of sync with lock manager!
> Nov  8 15:35:06 linux last message repeated 156 times
> 
> on a discless client system (root on NFS) with Kernel 2.6.18
> 
> Is this critical ? If not, can I supress it somehow ? It doesnt happen with the same server and my older clients (running 2.4.something).

It isn't critical. Usually it just means that someone is interrupting
NFS lock calls. You can suppress it by changing the 'console_loglevel'
field in /proc/sys/kernel/printk. Use something like

echo "3       3       1       7" > /proc/sys/kernel/printk

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
