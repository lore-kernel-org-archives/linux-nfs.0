From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS servers and ACCESS procedure
Date: 06 Aug 2003 08:05:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsbrv31fso.fsf@charged.uio.no>
References: <3F301DF5.4000002@cantv.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kHR6-00079i-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Aug 2003 23:06:12 -0700
To: Jesse Colmenares <jcolmenares@cantv.net>
In-Reply-To: <3F301DF5.4000002@cantv.net>
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


     >     The question is: There are a way no disable the ACCESS
     >     cheching on NFS version 3 clients o servers?

Not really. However there is a patch to make linux cache those ACCESS
checks in order to reduce the number of RPC calls. It has a very
noticable effect if you are running as root (for which the current
algorithm is very inefficient).

IOW: you have 3 obvious solutions.

  1) Use NFSv2...

  2) You could backport the ACCESS caching patch
        http://www.fys.uio.no/~trondmy/src/2.4.19/linux-2.4.19-21-access.dif
     to RedHat's 2.4.18 kernel.

  3) Upgrade to the RedHat 2.4.20 errata kernel, and apply the ACCESS
     caching patch for 2.4.20 to that.

Alternatively, RedHat may already have applied the ACCESS patch in
their rawhide kernels? Perhaps Steve Dickson could comment on that?

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
