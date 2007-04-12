From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: CentOS4.4 support NFSv4 Replication and Migration
Date: Thu, 12 Apr 2007 10:05:35 -0400
Message-ID: <4d569c330704120705t6166e8f6s60f745fe8bcffba@mail.gmail.com>
References: <003801c77cb1$42e77870$207ba8c0@barcelona>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Phillip Huang" <phuang@plasmon.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hbzvg-0000yI-1g
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 07:05:40 -0700
Received: from wr-out-0506.google.com ([64.233.184.236])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hbzvg-0000yG-9Q
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 07:05:42 -0700
Received: by wr-out-0506.google.com with SMTP id i20so581573wra
	for <nfs@lists.sourceforge.net>; Thu, 12 Apr 2007 07:05:37 -0700 (PDT)
In-Reply-To: <003801c77cb1$42e77870$207ba8c0@barcelona>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 4/11/07, Phillip Huang <phuang@plasmon.cn> wrote:
> Hi all,
>
> I have rebuild CentOS4.4 kernel with 2.6.20,
> and its original nfs-util is 1.0.6.

The nfs-utils support (server-side) for referrals went into
nfs-utils-1.0.12.  I don't recall exactly what version has the
necessary server-side kernel support, but I think 2.6.20 does.

Trond has client-side referral-related patches for 2.6.20 here:

http://www.linux-nfs.org/Linux-2.6.x/2.6.20/

which I believe will be in 2.6.21.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
