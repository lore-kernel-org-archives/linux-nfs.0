From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS mount version?
Date: Fri, 15 Aug 2003 10:57:35 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16188.12287.809594.752856@gargle.gargle.HOWL>
References: <20030813095312.GF4797@yeenoghu.progsoc.uts.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19nSua-00019y-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 17:57:48 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) (for <wildfire@progsoc.uts.edu.au>)
	By note With Smtp ; Fri, 15 Aug 2003 10:57:43 +1000
To: nfs@lists.sourceforge.net,
    wildfire@progsoc.uts.edu.au
In-Reply-To: message from Anand Kumria on Wednesday August 13
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

On Wednesday August 13, wildfire@progsoc.uts.edu.au wrote:
> Hi all,
> 
> Documentation/Changes in 2.6.0-test3 suggests the minimum version of 
> nfs-utils to use is 1.0.5 yet even with 1.0.5 I still get messages like:
> 
> Aug 13 18:09:35 clam kernel: nfs warning: mount version older than kernel 
> 
> Which version should I be using?

Some appropriate version of util-linux (I think).

nfs-utils does *not* contain the program that mounts nfs filesystems.
It is mostly server-side stuff.

util-linux contains mount which uses an old version and causes this
message.

However I don't think the message is of any real concern.  Things will
still work fine.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
