From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs root directory security
Date: Wed, 18 Jun 2003 13:47:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16111.57576.494626.387349@gargle.gargle.HOWL>
References: <1055888933.16259.54.camel@sleerssen.racemi.com>
	<16111.42521.693155.783206@gargle.gargle.HOWL>
	<1055904839.28760.4.camel@lodge.leerssen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19STr3-0006Tf-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 20:43:25 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <scott@leerssen.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 18 Jun 2003 13:43:17 +1000
To: Scott Leerssen <scott@leerssen.com>
In-Reply-To: message from Scott Leerssen on  June 17
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

On  June 17, scott@leerssen.com wrote:
> 
> Here's a specific example.  Let's say you have a data center and use
> network attached storage to maintain filesystems for all of your
> customers.  Since all customers have access to the NAS, and all have
> their own box with root access, it's not too difficult to go poking
> around on the NAS to find other folks' stuff.  One obvious way to deal
> with this is to have separate exported filesystems for each customer,
> however, that becomes a huge maintenance hassle if you have a few
> hundred customers.  This feature allows you to maintain all the
> filesystems under one NFS root, while hiding the filesystems of other
> customers.


So you want to hide the names from people who don't know them.
Sure removing read permission is enough. Without read permission you
cannot "ls" and so cannot find the names.

Alternately just export the subdirectories rather than the parent.
Export different subdirectories to different clients.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
