From: Amit Gud <agud@redhat.com>
Subject: Re: [PATCH] fix lazy and force umounts for mount.nfs
Date: Sat, 29 Jul 2006 03:20:41 -0400
Message-ID: <44CB0C49.8050508@redhat.com>
References: <44CA331E.2080004@redhat.com> <20060728162033.GP4324@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6j3m-0008RN-VX
	for nfs@lists.sourceforge.net; Sat, 29 Jul 2006 00:16:31 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G6j3l-0001uY-Tl
	for nfs@lists.sourceforge.net; Sat, 29 Jul 2006 00:16:31 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6T7GPLm024076
	for <nfs@lists.sourceforge.net>; Sat, 29 Jul 2006 03:16:25 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6T7GPsw002695
	for <nfs@lists.sourceforge.net>; Sat, 29 Jul 2006 03:16:25 -0400
Received: from [172.16.83.94] (dhcp83-94.boston.redhat.com [172.16.83.94])
	by mail.boston.redhat.com (8.12.8/8.12.8) with ESMTP id k6T7GPAB003826
	for <nfs@lists.sourceforge.net>; Sat, 29 Jul 2006 03:16:25 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20060728162033.GP4324@polop.usc.edu>
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

Garrick Staples wrote:
> On Fri, Jul 28, 2006 at 11:54:06AM -0400, Amit Gud alleged:
>> +	fprintf(stderr, "%s: %s: not found / mounted or server not reachable\n", progname, spec);
> 
> Call me dumb, but I don't know what "not found / mounted" means.  Is
> there a comma missing?
> 

Its "not found or not mounted or server not reachable." Might rephrase it :)


AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
