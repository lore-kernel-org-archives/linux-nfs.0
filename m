From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Why NFS server does not pass lock requests via VFS lock() op?
Date: 10 Oct 2002 00:32:02 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1034206322.1970.105.camel@irongate.swansea.linux.org.uk>
References: <OF3AABFEC7.87E5D2A4-ON87256C4D.007E3028@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net,
   Linux Kernel Mailing List
	 <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pc1-cwma1-5-cust42.swa.cable.ntl.com ([80.5.120.42] helo=irongate.swansea.linux.org.uk)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zQ8l-0000lp-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 16:21:19 -0700
To: Juan Gomez <juang@us.ibm.com>
In-Reply-To: <OF3AABFEC7.87E5D2A4-ON87256C4D.007E3028@us.ibm.com>
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

On Thu, 2002-10-10 at 00:11, Juan Gomez wrote:
> 
> 
> 
> 
> Could anyone remind me of why NFS kernel would not pass byte range lock
> requests to the underlying filsystem at the server side?
> I think another person at IBM (Brian?) submitted a patch for this but such
> patch never got included in the distribution.

I know Matthew had the patches, and I know I looked at them and they
seemed sane enough. But I don't know where they eventually went. Things
like NFS over AFS are going to need it



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
