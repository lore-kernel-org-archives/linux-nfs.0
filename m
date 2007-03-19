From: Steve Dickson <SteveD@redhat.com>
Subject: Re: rpc.statd  in /sbin or /usr/sbin ??
Date: Mon, 19 Mar 2007 08:52:18 -0400
Message-ID: <45FE8782.5020001@RedHat.com>
References: <17917.58341.502839.29524@notabene.brown>
	<200703190924.03153.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTHLi-0003xu-Dw
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 05:52:30 -0700
Received: from mx2.redhat.com ([66.187.237.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTHLj-0006lb-Hq
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 05:52:32 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx2.redhat.com (8.13.1/8.13.1) with ESMTP id l2JCqJ1s023759
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 08:52:20 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l2JCqJIM010256
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 08:52:19 -0400
Received: from [10.12.32.32] (dickson.boston.devel.redhat.com [10.12.32.32])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l2JCqJ3f007164
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 08:52:19 -0400
In-Reply-To: <200703190924.03153.olaf.kirch@oracle.com>
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



Olaf Kirch wrote:
> On Monday 19 March 2007 02:14, Neil Brown wrote:
>>  The only reason I can see for putting statd in /sbin is if it were
>>  needed for mounting /usr (in cases where /usr is accessed via NFS).
> 
> Can't speak for others, but this is the reason why Suse put it into /sbin too,
> as long as they shipped it.
I can only assuming this was the case as well... Red Hat has
been putting both rpc.lockd and rpc.statd in /sbin
since at least RH 7.1

steved.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
