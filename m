From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: remount error: 'unknown nfs mount option: v3'
Date: 30 Jul 2003 00:28:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy8yhufwt.fsf@charged.uio.no>
References: <20030728063639.GD2204@tenet.res.in>
	<20030729220602.GA18733@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nitin Chandrachoodan <nitin@tenet.res.in>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19hcxO-0002FZ-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Jul 2003 15:28:34 -0700
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20030729220602.GA18733@perlsupport.com>
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

>>>>> " " == Chip Salzenberg <chip@pobox.com> writes:

     > refuses to accept "v3", while the kernel only reports "v3".  It
     > seems like a pointless inconsistency.  Why not have mount
     > accept "v2", "v3", and "v4" as synoyms for the corresponding
     > "vers=" values?

Feel free...

Note however that vers=4 is unlikely ever to be supported. The entire
mount interface is so different from v2/v4 that I prefer to keep NFSv4
as a completely separate filesystem (i.e. 'mount -t nfs4').

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
