From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs root directory security
Date: Wed, 18 Jun 2003 09:36:57 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16111.42521.693155.783206@gargle.gargle.HOWL>
References: <1055888933.16259.54.camel@sleerssen.racemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SPwa-0004Pl-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 16:32:52 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <scott@leerssen.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 18 Jun 2003 09:32:27 +1000
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
> Attached is a patch for nfs-utils-1.0.1-2.9 (RedHat) that adds a bit of
> security and ease of use for exported filesystems that have lots of
> users in lots of subdirectories.
> 
> What it does is disallow nfs clients from mounting a directory that is
> marked execute only (chmod 0111), controlled by an option
> "root_mnt_orig".  This is handy if one has a constantly changing
> hierarchy of subdirectories where the client is the only one who knows
> where to look for his stuff.  Consider a directory structure that looks
> like:
> 
> /A/B/C/123
> /A/B/C/456
> /A/B/C/789
> 
> If A, B and C are mode 0111, the nfs client must directly mount 123,
> 456, or 789.  OK, this is a kind of lame example, but one can easily add
> some obscurity to the directory structure under /A and see how
> effectively this hides NFS mount points and adds some ease of use when
> maintaining a TON of mount points.

Hi.
I'm cannot see how this adds any significant security.

If you only want the client to mount certain bits, and the clients
know which bits to mount, then just mount those bits on the client.

Given that you allow the clients to mount any directories that they
have read access to, how does it hurt to allow them to mount parents
that they don't have read access to?
I can see that you don't want them to, but surely that is a client
configuration issue, not a server issue.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
