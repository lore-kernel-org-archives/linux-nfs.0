From: Ion Badulescu <ionut@cs.columbia.edu>
Subject: Re: Strange NFS happenings
Date: Fri, 5 Apr 2002 09:46:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200204051446.g35EkVv25310@buggy.badula.org>
References: <uqgj8a.6qt.ln@thune.mrc-home.org>
Cc: nfs@lists.sourceforge.net
Received: from bgp401130bgs.jersyc01.nj.comcast.net ([68.36.96.125] helo=buggy.badula.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16tUzC-0004EG-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Apr 2002 06:46:42 -0800
To: dalgoda@ix.netcom.com (Mike Castle)
In-Reply-To: <uqgj8a.6qt.ln@thune.mrc-home.org>
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

On Thu, 4 Apr 2002 22:39:26 -0800, Mike Castle <dalgoda@ix.netcom.com> wrote:
> In article <shsit77684e.fsf@charged.uio.no>,
> Trond Myklebust  <trond.myklebust@fys.uio.no> wrote:
>>The internals of shared mmap() do not allow you to overwrite a library
>>that is already in use. Try using 'cp' to copy into libcrypto.so while
>>ntpd is running on the server, and you will automatically get an
>>'ETXTBUSY' in return.
>>The problem is that the NFS protocol does not support leases ('cos of
>>the statelessness requirement), and so the clients have no way of
>>notifying the server that libcrypto should not be overwritten.
>>
>>Solution: use the GNU 'install' program whenever you want to update a
>>library. The latter creates a new file rather than overwriting the old
>>one, and avoids this kind of mess.
> 
> Considering that ntpd WAS running on the server when I reinstalled openssl,
> but it did a cp -f, so it should have done an unlink then copied it in.

Except that Trond was a bit wrong about ETXTBUSY: shared libraries don't 
get this kind of protection, only executables do. So your cp succeeded 
just fine, overwrote the library, then ntpd tried to page some code in
from the library and got garbage.

Never upgrade a shared library using cp, use install as Trond suggested...

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
