From: "Andrew Theurer" <habanero@us.ibm.com>
Subject: Re: [PATCH] zerocopy NFS updated
Date: Wed, 10 Apr 2002 12:55:00 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00a301c1e0b8$d6f1ce20$2e060e09@beavis>
References: <20020410.191231.130623162.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mg03.austin.ibm.com ([192.35.232.20])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vMFC-0005py-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Apr 2002 10:50:54 -0700
To: <nfs@lists.sourceforge.net>, "Hirokazu Takahashi" <taka@valinux.co.jp>
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





> Hi
>
> I add a new patch for zerocopy NFS.
> va03-knfsd-zerocopy-sendpage-2.5.7-test1.patch makes knfsd to skip
> csum_partial_copy_generic() which copies data into a sk_buff.
> This feature works on when you use NFS over TCP only at this moment.
> I'd like to implement sendpage for UDP, but it doesn't work yet.
>
> But I wonder about sendpage. I guess HW IP checksum for outgoing
> pages might be miscalculated as VFS can update them anytime.
> New feature like COW pagecache should be added to VM and they
> should be duplicated in this case.
>
> Is there anyone who could advise me about this ?
>
>
> Following patches patches are against linux 2.5.7
>
>
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.7/va01-knfsd-zerocopy-vfsre
ad-2.5.7.patch
>
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.7/va02-kmap-multplepages-2.
5.7.patch
>
>
ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.7/va03-knfsd-zerocopy-sendp
age-2.5.7-test1.patch
>
>
> Andrew,  Could you try it again?

Yes, thanks for the patch.  My first attempt resulted in a system which
would not respond anymore.  I did not have access to the console at the
time, so I am not sure why yet.  If it happens again, I'll have some data to
go along with it.  Once I get a working test, I should have some profiles
and throughput results.

Thanks again,

-Andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
