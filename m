From: Ion Badulescu <lists@news.cs.columbia.edu>
Subject: Re: nfs-utils 1.0.5 break amd?
Date: Tue, 5 Aug 2003 09:23:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308051323.h75DNEKM016040@buggy.badula.org>
References: <1060071722.2980.74.camel@ikarus>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-43524450.dyn.optonline.net ([67.82.68.80] helo=buggy.badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19k1mi-0005cS-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Aug 2003 06:23:28 -0700
To: Marc Schmitt <mschmitt@inf.ethz.ch>
In-Reply-To: <1060071722.2980.74.camel@ikarus>
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

On 05 Aug 2003 10:22:02 +0200, Marc Schmitt <mschmitt@inf.ethz.ch> wrote:
> Well, again it's me confusing stuff.
> With MOUNTD_TCP=no I thought I could prevent the clients from mounting
> the server with NFS over tcp... which is something I already have,
> because current RH kernels don't have NFS server support over TCP
> enabled in the kernel.

No, the transport protocol used to talk to mountd has no effect
whatsoever on the transport protocol used to talk to nfsd. Only the
version of the mountd protocol matters (and note that while mountd v3
corresponds to nfs v3, mountd v1 and v2 both correspond to nfs v2).

Since you use amd, you can always force it not to use tcp for nfs
mounts.  You can either do it globally for the client by setting
nfs_proto = udp in its amd.conf, or on a per mount entry basis by adding
proto = udp to that entry's mount options.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
