From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS attrib cache problems in 2.4.20 - 2.4.22-pre9
Date: Mon, 4 Aug 2003 00:38:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16173.36590.607019.119566@charged.uio.no>
References: <shsel05dgke.fsf@charged.uio.no>
	<Pine.LNX.4.44.0308010930320.5261-100000@fubar.phlinux.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    NFS List <nfs@lists.sourceforge.net>,
    <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jRVI-0001Fg-00
	for <nfs@lists.sourceforge.net>; Sun, 03 Aug 2003 15:39:04 -0700
To: Matt C <wago@phlinux.com>
In-Reply-To: <Pine.LNX.4.44.0308010930320.5261-100000@fubar.phlinux.com>
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

>>>>> " " == Matt C <Matt> writes:

     > Interesting. So the error condition you're describing would
     > happen when we mmap() a file descriptor, then munmap() it
     > followed by an ftruncate()? I guess I'm confused as to how this
     > plays into the attribute cache (or if that's a red herring)
     > since adding the 'noac' flag seems to make this problem go
     > away.

noac might change the timings a bit so that writepage() sees that the
page it is about to write out lies beyond the current file length.
I would tend to distrust that as a permanent solution though...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
