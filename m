From: Weikuan Yu <wyu@ornl.gov>
Subject: Re: NFS export of TMPFS
Date: Fri, 01 Dec 2006 17:36:55 -0500
Message-ID: <4570AE87.6070008@ornl.gov>
References: <4570A2C1.3060707@ornl.gov> <4570A407.6020007@redhat.com>
	<4570A51B.3080800@ornl.gov> <4570A597.2070106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GqH09-0000HI-6l
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 14:37:01 -0800
Received: from emroute1.ornl.gov ([160.91.4.119])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GqH08-0002T2-BL
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 14:37:02 -0800
Received: from emroute1.ornl.gov ([127.0.0.1])
	by emroute1.ornl.gov (PMDF V6.3-x3 #31246)
	with ESMTP id <0J9M002RT9HK7G@emroute1.ornl.gov> for
	nfs@lists.sourceforge.net; Fri, 01 Dec 2006 17:36:56 -0500 (EST)
In-reply-to: <4570A597.2070106@redhat.com>
To: Peter Staubach <staubach@redhat.com>
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



Peter Staubach wrote:
> Weikuan Yu wrote:
> 
>> Thansk for your prompt reply. Forgot to add that they are exported. 
>> Here  is the output from exportfs. The problem is I can nfs-mount 
>> /data (/dev/hda2) fine, but not /nfs (tmpfs). 
> 
> 
> Sorry, just a little cautious from the snippet of commands -- you
> exported /nfs _after_ it was created/mounted?  That wasn't shown
> in the list of commands...

Yes, you are right. Thanks for your suggestion.

Weikuan

> 
>    Thanx...
> 
>       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
