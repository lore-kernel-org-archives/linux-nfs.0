From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mount count is incremented incorrectly
Date: 14 Aug 2003 23:40:19 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsoeyr4e5o.fsf@charged.uio.no>
References: <20030814132006.7C2A.KAKMY@mvh.biglobe.ne.jp>
	<16188.13494.650071.936039@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>,  util-linux@math.uio.no,
	  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19nYGX-0001yH-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 23:40:50 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16188.13494.650071.936039@gargle.gargle.HOWL>
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

     > The MOUNT protocol is simply not a reliable way to keep rmtab
     > exactly correct.  Tinkering may improve the situation but it
     > can never make it perfect.

Seconded...

There is no way you can make this work exactly. It suffices for the
client to crash before it has sent the UNMOUNT request to the server
in order to screw up the accounting in rmtab.

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
