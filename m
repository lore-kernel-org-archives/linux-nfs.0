From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: NFSv4 Active-Active Cluster Queries
Date: Fri, 21 Jul 2006 13:27:07 -0400
Message-ID: <44C10E6B.4070000@redhat.com>
References: <44BCC5620200007F0000E2C6@lucius.provo.novell.com>	<44BCD1F80200007F0000E2CA@lucius.provo.novell.com>	<44BCE7BB0200007F0000E2E7@lucius.provo.novell.com>	<44BF54250200007F0000E3E0@lucius.provo.novell.com>	<44BF5EF80200007F0000E3E4@lucius.provo.novell.com>	<44BF5F580200007F0000E3E7@lucius.provo.novell.com>	<44BF5F8B0200007F0000E3EA@lucius.provo.novell.com>	<44BF607D0200007F0000E3ED@lucius.provo.novell.com>	<44BF6B4F0200007F0000E3F6@lucius.provo.novell.com>	<44BF6B870200007F0000E3F9@lucius.provo.novell.com>	<44BF6BA30200007F0000E3FC@lucius.provo.novell.com>	<44BF6BE60200007F0000E3FF@lucius.provo.novell.com>	<44BF6BE5.6FDC.007F.0@novell.com>
	<17599.11481.634050.489349@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3yma-0004A2-4s
	for nfs@lists.sourceforge.net; Fri, 21 Jul 2006 10:27:24 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G3yma-0007cG-AY
	for nfs@lists.sourceforge.net; Fri, 21 Jul 2006 10:27:24 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17599.11481.634050.489349@cse.unsw.edu.au>
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

Neil Brown wrote:

>On Thursday July 20, urajat@novell.com wrote:
>  
>
>>Hi,
>>
>>I have been working on setting up NFSv4 in cluster scenario. But when
>>it comes to an Active-Active setup, it seems there are a few problems. 
>>
>>    
>>
>>3) Locking issues - revocation & reacquiring of locks.
>>    
>>
>
>Wendy Cheng <wcheng@redhat.com> has been looking at what kernel/utils
>changes are needed to support this fully, though I think she is only
>looking at v3.
>
>  
>
The v3 patches are currently under function verification tests using 
RHCS cluser suite - so far so good 
(http://people.redhat.com/wcheng/Patches/NLM/). After documenting the 
procedure and restrictions, the formal submission (to nfs list) is 
scheduled at end of this month.
                                                                                

Not sure what to do with V4 yet .. need to chat with CITI folks first.
                                                                                

-- Wendy



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
