From: Neil Horman <nhorman@redhat.com>
Subject: Re: NFS response time
Date: Wed, 26 Jan 2005 07:46:54 -0500
Message-ID: <41F7913E.9030404@redhat.com>
References: <003a01c50326$73182550$7889b38b@alpin> <41F6BD96.4040409@redhat.com> <004101c50329$3e016b30$7889b38b@alpin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtmZh-0003lw-QQ
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 04:47:09 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CtmZg-00033v-5a
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 04:47:09 -0800
To: Duv Dek <onur@ee.bilkent.edu.tr>
In-Reply-To: <004101c50329$3e016b30$7889b38b@alpin>
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

Duv Dek wrote:
> Yes, it is program that we wrote. It is doing some mathematical 
> calculations, so it utilizes full CPU. Other linux programs are not 
> getting very slow when this program runs, but client computers sometimes 
> wait half a minute in order to reach a file on nfs server. Logging in to 
> the client computers take around 10 minutes. Normally it takes no more 
> than 20 seconds. I mean nfs  is almost locking, but no other linux 
> program is badly affected. At least we should be able to give better 
> priority nfs via renice but we couldn't figure it out. Doing renice -20 
> to all root programs didn't make nfs faster.
> 
I assume that you included your program in the renice?  If it still 
didn't help, my immediate thought would be to enable nfsd_debug, try to 
access the NFS share from a client, and check the message log.  That 
would at least tell you if the NFS server is receiving the NFS 
transactions, and if so, where they might be taking the most time in 
processing.  That may give you a clue as to where the delay is comming 
from, be it a scheduling delay from high CPU load, or contention on 
another resource that is in short supply on your system.
Neil

> 
> 
> ----- Original Message ----- From: "Neil Horman" <nhorman@redhat.com>
> To: "Duv Dek" <onur@ee.bilkent.edu.tr>
> Cc: <nfs@lists.sourceforge.net>
> Sent: Tuesday, January 25, 2005 11:43 PM
> Subject: Re: [NFS] NFS response time
> 
> 
>> Duv Dek wrote:
>>
>>> Hi
>>>  We have a problem with our NFS server on Redhat 9. In case a program 
>>> on the server uses high CPU, the NFS clients almost lock and nfs 
>>> stops giving response until that program lowers its CPU usage.  We 
>>> tried to increase the priority of nfsd deamons with renice, and also 
>>> tried to increase the number of nfsd threads, decreased the priority 
>>> of the program using high CPU with renice, but none of them worked. 
>>> How can we solve this problem so that nfs does not lock?
>>>
>> Have your tried to ascertain which process on your system is 
>> responsible (or most responsible) for the high CPU utilization?
>>
>> Neil
>>
>> -- 
>> /***************************************************
>>  *Neil Horman
>>  *Software Engineer
>>  *Red Hat, Inc.
>>  *nhorman@redhat.com
>>  *gpg keyid: 1024D / 0x92A74FA1
>>  *http://pgp.mit.edu
>>  ***************************************************/
>>
> 


-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
