From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH] zerocopy NFS updated
Date: Sat, 13 Apr 2002 18:40:28 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020413.184028.69377819.taka@valinux.co.jp>
References: <20020410.191231.130623162.taka@valinux.co.jp>
	<009501c1e212$b30e6bc0$2e060e09@beavis>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16wK1X-0005kG-00
	for <nfs@lists.sourceforge.net>; Sat, 13 Apr 2002 02:40:48 -0700
To: habanero@us.ibm.com
In-Reply-To: <009501c1e212$b30e6bc0$2e060e09@beavis>
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

Hello,

I really appreciate your help!

> I tried the patch with great performance improvement!   I ran my nfs read
> test (48 clients read 200 MB file from one 4-way SMP NFS server) and
> compared your patches to regular 2.5.7.  Regular 2.5.7 resulted in 87 MB/sec
> with 100% CPU utilization.  Your patch resulted 130 MB/sec with 82% CPU
> utilization!  This is very good!  I took profiles, and as expected,
> csum_copy and file_read_actor were gone with the patch.  Sar reported nearly
> 40 MB/sec per gigabit adapter (there are 4) during the test.  That is the
> most I have seen so far.  Soon I will be doing some lock analysis to make
> sure we don't have any locking problems.  Also, I will see if there is
> anyone here at IBM LTC that can assist with your development of zerocopy on
> UDP.  Thanks for the patch!

I'd love to develop it with your team.
I have some ideas to implement it and I'm thinking about them.

Thank you,
Hirokazu Takahashi

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
