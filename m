From: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
Subject: Re: Strange behavior of executable bit
Date: Wed, 26 May 2004 12:48:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40B4761A.6020705@byggmek.lth.se>
References: <40B44FE7.6010601@byggmek.lth.se> <40B462A3.1070704@RedHat.com> <40B4708F.1070707@byggmek.lth.se> <40B47557.2000400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSvyB-0002Vz-K7
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 03:49:11 -0700
Received: from av9-1-sn1.fre.skanova.net ([81.228.11.115])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BSvyB-0007qv-3d
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 03:49:11 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40B47557.2000400@RedHat.com>
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

Steve Dickson wrote:

> Jonas Lindemann wrote:
>
>> Steve Dickson wrote:
>>
>>> I guess I'm  a bit confused... What are the expected results or
>>> what do you mean by "stabilizes"?
>>
>>
>> The file is uploaded via a gridftp. A special service is responsible 
>> for marking certain files as executable in the above case "test.sh". 
>> The testscript is called directly after this service has set the bit. 
>> The problem seems to be that this bit is not directly set, and 
>> execution of this file fails. Rebooting the server makes the problem 
>> go away for about a week, then it resurfaces again.
>
>
> So are you saying that the client has the directory mounted and then
> this special service runs (on the server) setting the executable bit 
> on test.sh
> but the client never sees that bit being set?

The service runs on the client, and does not see this bit when queried.

>
> SteveD.
>




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
