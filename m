From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [BUG] [FIX] exportfs dput() problems.
Date: Wed, 18 Sep 2002 15:22:00 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15752.3448.983631.534347@notabene.cse.unsw.edu.au>
References: <20020917.170140.51696587.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rXHx-0007up-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 22:22:13 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 18 Sep 2002 15:22:04 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Tuesday September 17
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Tuesday September 17, taka@valinux.co.jp wrote:
> Hello,
> 
> There are bugs in fs/exportfs/expfs.c to be fixed.
> 
> 1) dput() might be called twice against the same dentry as local
>    variable "toput" in find_exported_dentry() is not cleared when
>    dput() is called so that following code may misunderstand that
>    it's still alive.
> 
> 2) Some dentries might not be released in case of ENOENT error.
> 

Thanks for catching these to.  I will forward them as appropriate.

NeilBrown


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
