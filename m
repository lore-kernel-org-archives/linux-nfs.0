From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: 19 Sep 2002 00:54:37 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1032393277.24895.8.camel@irongate.swansea.linux.org.uk>
References: <20020918.171431.24608688.taka@valinux.co.jp>
	<20020918.160057.17194839.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: taka@valinux.co.jp, neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
   nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pc1-cwma1-5-cust128.swa.cable.ntl.com ([80.5.120.128] helo=irongate.swansea.linux.org.uk)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rodN-00085g-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 16:53:29 -0700
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

On Thu, 2002-09-19 at 00:00, David S. Miller wrote:
> It was discussed long ago that csum_and_copy_from_user() performs
> better than plain copy_from_user() on x86.  I do not remember all

The better was a freak of PPro/PII scheduling I think

> details, but I do know that using copy_from_user() is not a real
> improvement at least on x86 architecture.

The same as bit is easy to explain. Its totally memory bandwidth limited
on current x86-32 processors. (Although I'd welcome demonstrations to
the contrary on newer toys)



-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
