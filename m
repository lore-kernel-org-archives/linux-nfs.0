From: Ion Badulescu <ionut@badula.org>
Subject: Re: nfs-utils 1.0.5 break amd?
Date: Mon, 4 Aug 2003 12:05:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308041605.h74G5uRc003894@buggy.badula.org>
References: <1059672742.21271.58.camel@ikarus>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-43524450.dyn.optonline.net ([67.82.68.80] helo=buggy.badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jhqk-00058s-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 09:06:18 -0700
To: Marc Schmitt <mschmitt@inf.ethz.ch>
In-Reply-To: <1059672742.21271.58.camel@ikarus>
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

On 31 Jul 2003 19:32:22 +0200, Marc Schmitt <mschmitt@inf.ethz.ch> wrote:

> After upgrading a RedHat 7.3 box with kernel 2.4.18-27.7xsmp from
> nfs-utils 1.0.3 to 1.0.5, amd stopped working.
> 
> On the client (am-utils-6.0.7-4, nfs-utils-0.3.3-6.73), I issue:
> 
> ls /net/<fileserver>
> 
> With 1.0.3, I get the correct directory listing under /net/<fileserver>
> 
> With 1.0.5, I get:
> ls: /net/<fileserver>: Input/output error

Can you mount any shares from <fileserver> by hand, using mount? If not, 
as I suspect, then the problem is not amd.

Ion
[amd co-maintainer]

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
