From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [ltc-perf] draft of nfs event hook
Date: Wed, 26 Jul 2006 10:13:14 +0100
Message-ID: <20060726091314.GA3739@infradead.org>
References: <OF053E04B8.D96A9ADC-ON482571B7.0031B2AD-482571B7.00323E27@cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: varap@us.ibm.com, ltc-perf@linux.ibm.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G677A-00081h-Jj
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 07:45:28 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6779-0002n7-59
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 07:45:28 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G5fSF-00078r-Dx
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 02:13:26 -0700
To: Xue Peng Li <xuepengl@cn.ibm.com>
In-Reply-To: <OF053E04B8.D96A9ADC-ON482571B7.0031B2AD-482571B7.00323E27@cn.ibm.com>
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

On Wed, Jul 26, 2006 at 05:13:09PM +0800, Xue Peng Li wrote:
> 
> Hi folks,
> 
>   I am working on NFS trace hooks for SystemTap/LKET. These trace
> hooks could be used for performance analyzing which will trace both
> NFS client and server side activities.
> 
>   At the first step I need make sure that the trace hooks I defined
> are appropriate and every trace hook probes the right places inside
> the Kernel. So I will be appreciated if you could help me review the
> following trace hooks.

Please implement proper static traces based on something similar to the
blktrace instead of wasting your time systemtap.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
