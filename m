From: "Andrew Theurer" <habanero@us.ibm.com>
Subject: Re: [PATCH] zerocopy NFS updated
Date: Fri, 12 Apr 2002 06:10:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <009501c1e212$b30e6bc0$2e060e09@beavis>
References: <20020410.191231.130623162.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mg01.austin.ibm.com ([192.35.232.18])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vyt1-0001tG-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Apr 2002 04:06:35 -0700
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

I tried the patch with great performance improvement!   I ran my nfs read
test (48 clients read 200 MB file from one 4-way SMP NFS server) and
compared your patches to regular 2.5.7.  Regular 2.5.7 resulted in 87 MB/sec
with 100% CPU utilization.  Your patch resulted 130 MB/sec with 82% CPU
utilization!  This is very good!  I took profiles, and as expected,
csum_copy and file_read_actor were gone with the patch.  Sar reported nearly
40 MB/sec per gigabit adapter (there are 4) during the test.  That is the
most I have seen so far.  Soon I will be doing some lock analysis to make
sure we don't have any locking problems.  Also, I will see if there is
anyone here at IBM LTC that can assist with your development of zerocopy on
UDP.  Thanks for the patch!

Andrew Theurer


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
>
>
> Regards,
> Hirokazu Takahashi
>
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
