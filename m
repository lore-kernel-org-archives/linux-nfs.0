From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mount version?
Date: 14 Aug 2003 23:31:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shssmo34eka.fsf@charged.uio.no>
References: <20030813095312.GF4797@yeenoghu.progsoc.uts.edu.au>
	<16188.12287.809594.752856@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,  wildfire@progsoc.uts.edu.au
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19nY86-0007ns-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 23:32:07 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16188.12287.809594.752856@gargle.gargle.HOWL>
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

>>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:

     > On Wednesday August 13, wildfire@progsoc.uts.edu.au wrote:
    >> Hi all,
    >>
    >> Documentation/Changes in 2.6.0-test3 suggests the minimum
    >> version of nfs-utils to use is 1.0.5 yet even with 1.0.5 I
    >> still get messages like:
    >>
    >> Aug 13 18:09:35 clam kernel: nfs warning: mount version older
    >> than kernel
    >>
    >> Which version should I be using?

     > Some appropriate version of util-linux (I think).

Actually, support for NFS_MOUNT_VERSION 5 has not yet been merged into
any version of util-linux.

Note, though, that the only new feature added is support for
RPCSEC_GSS under NFSv2 and NFSv3. Unless you have some burning desire
to test krb5 authentication, you can ignore the above warning.

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
