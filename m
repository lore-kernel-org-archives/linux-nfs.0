From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: v3 client generates too many "access" requests
Date: Tue, 10 Dec 2002 12:05:03 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200212101205.03533.trond.myklebust@fys.uio.no>
References: <m34r9mei56.fsf@zsu.sush.org> <shsy96yci8j.fsf@charged.uio.no> <m3y96yb0o5.fsf@zsu.sush.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18LiCM-0002Bj-00
	for <nfs@lists.sourceforge.net>; Tue, 10 Dec 2002 03:05:10 -0800
To: Istvan Marko <mi@imarko.dhs.org>
In-Reply-To: <m3y96yb0o5.fsf@zsu.sush.org>
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

On Tuesday 10 December 2002 11:58, Istvan Marko wrote:

> Thank you Trond, you are right on the mark! But what exactly is going
> on here? Is this related to root_squash (or the Netapp equivalent)? Is
> it just ./configure that does something weird or are there other
> common situations where this "access storm" might get triggered with
> an NFS mounted /usr?

In 2.4.x, the NFSv3 ACCESS call is not fully implemented: it lacks the ability 
to cache results. For this reason it is only used to check for root squashing 
and for those specific cases where the kernel tries to override the standard 
UNIX mode permission checks.

In 2.5.x, on the other hand, access checking *is* cached.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
