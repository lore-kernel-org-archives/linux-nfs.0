From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs-utils 1.0.5 break amd?
Date: Fri, 1 Aug 2003 13:12:50 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16169.55986.854984.818132@gargle.gargle.HOWL>
References: <1059672742.21271.58.camel@ikarus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19iQLs-00012s-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 20:13:08 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <mschmitt@inf.ethz.ch>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Fri, 1 Aug 2003 13:12:55 +1000
To: Marc Schmitt <mschmitt@inf.ethz.ch>
In-Reply-To: message from Marc Schmitt on  July 31
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

On  July 31, mschmitt@inf.ethz.ch wrote:
> Hi all,
> 
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

Wierd.

> 
> 
> On the server, with 1.0.3, I'd see an entry for every export in
> /etc/exports in /var/log/messages, mount refused or granted, according
> to the export permissions. 
> With 1.0.5, I get one single entry:
> Jul 31 19:14:34 <fileserver> rpc.mountd: export request from <client>
> 

Can you run
   showmount -e <fileserver>
on <client> and see what it returns?
If it doesn't return the right stuff, maybe strace mountd on the
server while you are running the showmout on the client.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
