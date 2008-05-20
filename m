From: "Marcelo Leal" <diversos-roWltSPQdMkZWYhx5MAOMFAUjnlXr6A1@public.gmane.org>
Subject: Re: [NFS] async vs. sync. corrupted fs
Date: Tue, 20 May 2008 15:56:56 -0300
Message-ID: <42996ba90805201156m273ad3caif87876fc70421af8@mail.gmail.com>
References: <215ff4410805160355x25b8d055x9a0a246aa5875482@mail.gmail.com>
	<20080519145411.GC7622@fieldses.org>
	<215ff4410805200100o20fb83bcm9921127efef27ef9@mail.gmail.com>
	<1211288508.13163.13.camel@localhost>
	<42996ba90805200705o49b4a17bn62cc9962bbcac8b2@mail.gmail.com>
	<1211300873.14155.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chris Fanning <christopher.fanning@gmail.com>,
	nfs@lists.sourceforge.net
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:60298 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbYETS5Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 14:57:16 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JyX1N-000269-7q
	for linux-nfs@vger.kernel.org; Wed, 21 May 2008 04:57:13 +1000
In-Reply-To: <1211300873.14155.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NO, but is in a older XFS version...  i just wrote because is a
similar situation, i gues...

2008/5/20 Trond Myklebust <trond.myklebust@fys.uio.no>:
> On Tue, 2008-05-20 at 11:05 -0300, Marcelo Leal wrote:
>> We already saw xfs filesystem full and NFS server (2.4 kernel),
>> produce a disc corruption (partition table goes away).
>> But believe me, not in the full disc, but in another one (we can
>> reproduce). Always the same disc is corrupted (the first one i guess).
>
> That would be an XFS bug. Have you reported it?
>
>  Trond
>
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2008.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>    http://vger.kernel.org/vger-lists.html#linux-nfs
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



-- 
pOSix rules

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft 
Defy all challenges. Microsoft(R) Visual Studio 2008. 
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

