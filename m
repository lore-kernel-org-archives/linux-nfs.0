From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH] zerocopy NFS updated
Date: Wed, 10 Apr 2002 19:05:50 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020410.190550.83626375.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vEz7-0005cr-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Apr 2002 03:05:50 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi

I add a new patch for zerocopy NFS.
va03-knfsd-zerocopy-sendpage-2.5.7-test1.patch makes knfsd to skip
csum_partial_copy_generic() which copies data into a sk_buff.
This feature works on when you use NFS over TCP only at this moment.
I'd like to implement sendpage for UDP, but it doesn't work yet.

But I wonder about sendpage. I guess HW IP checksum for outgoing
pages might be miscalculated as VFS can update them anytime.
New feature like COW pagecache should be added to VM and they 
should be duplicated in this case.

Is there anyone who could advise me about this.


Following patches patches are against linux 2.5.7

ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.7/va01-knfsd-zerocopy-vfsread-2.5.7.patch
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.7/va02-kmap-multplepages-2.5.7.patch

ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.7/va03-knfsd-zerocopy-sendpage-2.5.7-test1.patch


Andrew,  Could you try it again?


Regards,
Hirokazu Takahashi

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
