From: Ion Badulescu <ionut@badula.org>
Subject: Re: mountd through a firewall?
Date: Thu, 20 Feb 2003 09:10:33 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302201410.h1KEAXaB002624@buggy.badula.org>
References: <3E540BAE.9090903@motorola.com>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lrPS-0002Uh-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 06:10:46 -0800
To: Robert Rati <Robert.Rati@motorola.com>
In-Reply-To: <3E540BAE.9090903@motorola.com>
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

On Wed, 19 Feb 2003 16:56:46 -0600, Robert Rati <Robert.Rati@motorola.com> wrote:
> 
> When I start rpc.mountd, I notice that it always registers 4 ports with 
> portmapper.  2 TCP and 2 UDP, which corespond to two separate instances 
> of mountd.  When I run exportfs, I see that no file systems are being 
> exported.  If I export a file system, the only difference is exportfs 
> shows a file system being exported.  This will obviously cause a problem 
> if I try to specify a port for rpc.mountd to run on as both instances of 
> mountd try to use the same port and the tcp bind for the second instance 
> fails.  Why does rpc.mountd start two instances of mountd?

It doesn't, so you must be doing something very wrong on your system -- 
are you starting a second mountd or something?

This is my system:

$ ps ax |grep mountd
26351 ?        S      0:01 rpc.mountd
$ rpcinfo -p | grep mountd
    100005    1   udp   4112  mountd
    100005    1   tcp   3231  mountd
    100005    2   udp   4112  mountd
    100005    2   tcp   3231  mountd
    100005    3   udp   4112  mountd
    100005    3   tcp   3231  mountd

One process, six ports, no problem.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
