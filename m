From: James Pearson <james-p@moving-picture.com>
Subject: Re: Typo in Redhat 8/9 nfs start/stop script
Date: Fri, 20 Jun 2003 15:30:23 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF31A7F.10E41E79@moving-picture.com>
References: <D38AFB3080F3D311807300B0D0203E53033A9616@MERCURY> <1056116269.18560.5.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TMv1-0000h3-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 07:31:12 -0700
To: Matt Schillinger <mschilli@vss.fsi.com>
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

Matt Schillinger wrote:
...
> Also, 2.4.20.. would it be better for me to use that as opposed to
> 2.4.19? I use a vanilla kernel with an NFSD patch that creates a
> workaround for an IRIX < 6.5.13 CWD bug.  If it is recommended to go to
> 2.4.20, does anyone know if that patch is available for 2.4.20?
> Actually, I've forgotten my source for that patch, so if anyone knows
> the address, i'd greatly appreciate recieving that info.
...

If that's the patch/hack I did - from:

 ftp://ftp.moving-picture.com/private/james/linux-2.4.19-nfsfh.patch

then it should work OK with 2.4.20 and 2.4.21

James Pearson


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
