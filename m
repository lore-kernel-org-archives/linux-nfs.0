From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Code Query: Frustrating ERR_ACCESS error with rpc.mountd while mounting.
Date: Fri, 15 Aug 2003 11:21:32 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16188.13724.312400.531099@gargle.gargle.HOWL>
References: <E19n6s4-0000z4-00@sc8-sf-list2.sourceforge.net>
	<3F3AF699.300@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19nTHm-00066s-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 18:21:46 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <devnull001@fastmail.fm>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Fri, 15 Aug 2003 11:21:35 +1000
To: "Vinay A. Mahadik" <devnull001@fastmail.fm>
In-Reply-To: message from Vinay A. Mahadik on Wednesday August 13
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

On Wednesday August 13, devnull001@fastmail.fm wrote:
> I have been trying to add code to our RPC library (for a scanner) to
> MOUNT remote directories. While DUMP, EXPORT, and other calls work just
> fine, I am consistently getting an ERR_ACCESS (0x0d) permission denied. 
> The confusing thing is:
> 
> - I have checked the server side config, infact, using "mount" directly
> from the same IP works just fine
> - /etc/exports is just "/tmp/tmp -ro"

That doesn't look like valid syntax - for a Linux server at least.
It should be
    /tmp/tmp (ro)

> - The following show the network packets from "mount" and my code -
> quite identical I guess.

Except for source port number...
> 
> Is there something I am missing? I have spent several hours trying to
> debug this stuff with no progress.

Either:
  the request must come from a port number < 1024
or 
  the "insecure" export option must be given:
    /tmp/tmp (ro,insecure)

> 
> Any hints/input will be greatly appreciated!

You're welcome.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
