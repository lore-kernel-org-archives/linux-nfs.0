From: Pavel Machek <pavel@elf.ucw.cz>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Sat, 21 Sep 2002 13:56:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020921115619.GA1000@elf.ucw.cz>
References: <20020918.171431.24608688.taka@valinux.co.jp> <20020918.160057.17194839.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: taka@valinux.co.jp, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [195.39.17.254] (helo=Elf.ucw.cz)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sisK-0004Yw-00
	for <nfs@lists.sourceforge.net>; Sat, 21 Sep 2002 04:56:42 -0700
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020918.160057.17194839.davem@redhat.com>
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

Hi!
>    
>    1)
>    ftp://ftp.valinux.co.jp/pub/people/taka/2.5.36/va10-hwchecksum-2.5.36.patch
>    This patch enables HW-checksum against outgoing packets including UDP frames.
>    
> Can you explain the TCP parts?  They look very wrong.
> 
> It was discussed long ago that csum_and_copy_from_user() performs
> better than plain copy_from_user() on x86.  I do not remember all
> details, but I do know that using copy_from_user() is not a real
> improvement at least on x86 architecture.

Well, if this is the case, we need to #define copy_from_user csum_and_copy_from_user :-).

								Pavel
-- 
I'm pavel@ucw.cz. "In my country we have almost anarchy and I don't care."
Panos Katsaloulis describing me w.r.t. patents at discuss@linmodems.org


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
