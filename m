From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: 2.4.20 changelog
Date: Sat, 21 Jun 2003 15:23:29 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16115.60369.756894.899436@gargle.gargle.HOWL>
References: <1056120449.18560.13.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TUy7-0005lc-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 16:06:55 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <mschilli@vss.fsi.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Sat, 21 Jun 2003 09:06:44 +1000
To: Matt Schillinger <mschilli@vss.fsi.com>
In-Reply-To: message from Matt Schillinger on  June 20
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

On  June 20, mschilli@vss.fsi.com wrote:
> In the Linux kernel-2.4.20 Changelog, I find this reference..
> 
> <okir@suse.de>:
>   o Fix NFS IRIX compatibility braindamage
> 
> does this relate to the IRIX < 6.5.13 CWD Bug?

No.  It fixes an much more obscure problem.
IRIX  uses a CREATE request to check if it has write permission on a
device special file (incase ACLs are in use on the server).  These
needs to allow write permission (if appropriate) even if the
filesystem is exported read-only.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
