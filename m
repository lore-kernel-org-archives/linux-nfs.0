From: Steve Dickson <SteveD@redhat.com>
Subject: Re: time after which statd gives up
Date: Tue, 05 Jul 2005 09:57:55 -0400
Message-ID: <42CA91E3.5070900@RedHat.com>
References: <20050705115035.78035.qmail@web51608.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dpnw4-0006rx-1q
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 06:58:04 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1Dpnw2-000587-V0
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 06:58:04 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050705115035.78035.qmail@web51608.mail.yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

mehta kiran wrote:
> Hi , 
>       On RHEL4 U1 i have observed that statd
>       sends notification only till the 
>       max(if cannot notify) time 30 seconds.
To be clear, you saying when rpc.statd is started
it sends out SM_NOTIFY messages notifying the clients
this machine just rebooted and it seems to do this for
30 seconds?

> 
>       Is this the expected behavior ?
Again not knowing the type of message you seeing, its
hard to tell...

steved.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
