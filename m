From: "Vinay A. Mahadik" <devnull001@fastmail.fm>
Subject: Re: Code Query: Frustrating ERR_ACCESS error with rpc.mountd
 while mounting.
Date: Fri, 15 Aug 2003 22:14:39 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F3DBDBF.5050700@fastmail.fm>
References: <E19n6s4-0000z4-00@sc8-sf-list2.sourceforge.net>	<3F3AF699.300@fastmail.fm> <16188.13724.312400.531099@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Vinay A. Mahadik" <devnull001@fastmail.fm>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from out4.smtp.messagingengine.com ([66.111.4.28] helo=mail.messagingengine.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19nt8D-0001WR-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Aug 2003 21:57:37 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Neil Brown wrote:
> 
> Either:
>   the request must come from a port number < 1024
> or 
>   the "insecure" export option must be given:
>     /tmp/tmp (ro,insecure)

Excellent reply; it worked just right with port number < 1024 .

Thanks much,
Vinay.



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
