From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: mountd getfh failure
Date: Fri, 8 Aug 2003 11:13:48 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16178.63820.217500.575020@gargle.gargle.HOWL>
References: <20030806092122.GB3069@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kvpX-0006va-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Aug 2003 18:14:07 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <wichert@wiggy.net>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 8 Aug 2003 11:13:54 +1000
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: message from Wichert Akkerman on Wednesday August 6
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

On Wednesday August 6, wichert@wiggy.net wrote:
> I'm struggling with a problem with nfsd in 2.6.0-test2. Yesterday I had
> some problems with nfsd, but trying to reproduce them today I found that
> mountd no longer works: when I try to mount a NFS export from another
> machine I get the following in my syslog:
> 
> Aug  6 11:11:34 thunder rpc.mountd: authenticated mount request from tornado.home.wiggy.net:857 for /home (/home)
> Aug  6 11:11:34 thunder rpc.mountd: getfh failed: Operation not permitted
> 
> A strace of rpc.mountd confirms the problem:
> 
> nfsservctl(0x8, 0xbfffdcb0, 0x8057ba0)  = -1 EPERM (Operation not permitted)
> 
> I'm a bit at a loss as to what the problem is here..

Can you send me the contents of /proc/net/*/content and let me know
the IP address of tornado....

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
