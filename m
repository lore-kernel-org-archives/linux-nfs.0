From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [NFS][PATCH] zerocopy NFS
Date: Mon, 08 Apr 2002 22:29:06 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <a8s62e$j9m$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uZCc-0000Qd-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 06:28:58 -0700
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

Hello

I'm tuning knfsd and I implemented zerocopy knfsd.
Everyone knows knfsd copies file data many times,
so I tried to reduce the copies. 
nfsd_read() doesn't copy filedata anymore.
This works pretty fine and performance is improved.

Following patches patches are against linux 2.5.7

ftp:/ftp.valinux.co.jp/pub/people/taka/tune/2.5.7/va01-knfsd-zerocopy-vfsread-2.5.7.patch
ftp:/ftp.valinux.co.jp/pub/people/taka/tune/2.5.7/va02-kmap-multplepages-2.5.7.patch

I also have patches against linux 2.4.18

ftp:/ftp.valinux.co.jp/pub/people/taka/tune/2.4.18/va01-knfsd-zerocopy-vfsread-2.4.18.patch
ftp:/ftp.valinux.co.jp/pub/people/taka/tune/2.4.18/va02-kmap-multplepages-2.4.18.patch


Now I'm designing new mechanism to send pagecache directly 
using sendpage.

I'm waiting for your comments.


Regards,
Hirokazu Takahashi
VP Engineering Dept.
VA Linux Systems Japan

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
