From: "Gareth Glaccum" <verycoldpenguin@hotmail.com>
Subject: Re: NFS using too much memory on diskless system
Date: Thu, 24 Feb 2005 14:14:55 +0000
Message-ID: <BAY101-F402EAE1436EB8C3874B5D8BD640@phx.gbl>
References: <421DD8C4.6080702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4Jm1-0007yN-P3
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 06:15:25 -0800
Received: from bay101-f40.bay101.hotmail.com ([64.4.56.50] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D4Jm0-0003JQ-9i
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 06:15:25 -0800
In-Reply-To: <421DD8C4.6080702@redhat.com>
To: nfs@lists.sourceforge.net
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

Hi Neil,
Thanks for the pointer,
a
sysctl -w vm.dirty_ratio=0
appears to have removed the problems, I shall continue to investigate this.
Thanks,
Gareth

>From: Neil Horman <nhorman@redhat.com>
>>Is there some way of limiting the NFS cache size like there used to be in 
>>the 2.4 kernel? (see section B7 of the nfs FAQ I believe)
>>
>>Any ideas gratefully received,
>>Gareth
>>
>It sounds to me your kernel has some sort of vm bug, but if you want to 
>shrink page cache usage, you may want to play with the dirty_vm_* settings 
>in /proc/sys/vm.  I'm still getting used to the 2.6 sysctls, but I believe 
>that those settings allow you to specify when your kernel decides its under 
>sufficient memory pressure to start moving data back to disk.
>
>HTH
>Neil
>>_________________________________________________________________

_________________________________________________________________
Express yourself with cool new emoticons http://www.msn.co.uk/specials/myemo



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
