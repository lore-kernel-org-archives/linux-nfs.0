From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: It works, but it doesn't
Date: Thu, 07 Aug 2003 16:49:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F3266E6.5020508@inf.ethz.ch>
References: <1060266746.32702.13.camel@engw0002.eng.lsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19km4n-0006ZX-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Aug 2003 07:49:13 -0700
To: Steve Gonzales <gonzo@eng.lsu.edu>
In-Reply-To: <1060266746.32702.13.camel@engw0002.eng.lsu.edu>
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

Hi Steve,

Try:

Server /etc/exports:
/install/RedHat/9 <IPAddr2>(ro,no_root_squash) <IPAddr3>(ro,no_root_squash)

AFAIK, one can only have one entry per exported directory (in your case /install/RedHat/9).

Greetings
   Marc





-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
