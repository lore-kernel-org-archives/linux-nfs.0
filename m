From: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
Subject: Re: Strange behavior of executable bit
Date: Wed, 26 May 2004 12:42:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40B47478.4020101@byggmek.lth.se>
References: <40B44FE7.6010601@byggmek.lth.se> <40B462A3.1070704@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSvrN-00019U-5r
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 03:42:09 -0700
Received: from av3-1-sn3.vrr.skanova.net ([81.228.9.109])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSvrM-000797-OZ
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 03:42:08 -0700
Received: from smtp1-2-sn3.vrr.skanova.net (smtp1-2-sn3.vrr.skanova.net [81.228.9.178])
	by av3-1-sn3.vrr.skanova.net (Postfix) with ESMTP id A474137E4B
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 12:42:02 +0200 (CEST)
Received: from byggmek.lth.se (h5n2fls309o1101.telia.com [81.226.193.5])
	by smtp1-2-sn3.vrr.skanova.net (Postfix) with ESMTP id 858113801F
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 12:42:02 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <40B462A3.1070704@RedHat.com>
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
>> Running the following script:
>>
>> for i1 in 0 1 2 3 4 5 6 7 8 9 ; do
>> for i2 in 0 1 2 3 4 5 6 7 8 9 ; do
>> for i3 in 0 1 2 3 4 5 6 7 8 9 ; do
>> ls -l "$joboption_directory/test.sh" 1>&2
>> /bin/usleep 100000
>> done
>> done
>> done
>>
>>
>> Produce these results:
>>
>> And then it stabilizes.
>
>
> I guess I'm  a bit confused... What are the expected results or
> what do you mean by "stabilizes"?

The file is uploaded via a gridftp. A special service is responsible for
marking certain files as executable in the above case "test.sh". The
testscript is called directly after this service has set the bit. The
problem seems to be that this bit is not directly set, and execution of
this file fails. Rebooting the server makes the problem go away for
about a week, then it resurfaces again.

-- Jonas

>
> SteveD.
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: Oracle 10g
> Get certified on the hottest thing ever to hit the market... Oracle 
> 10g. Take an Oracle 10g class now, and we'll give you the exam FREE.
> http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>





-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
