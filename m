From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Strange behavior of executable bit
Date: Wed, 26 May 2004 10:02:46 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40B4A386.8090403@RedHat.com>
References: <40B44FE7.6010601@byggmek.lth.se> <40B462A3.1070704@RedHat.com> <40B4708F.1070707@byggmek.lth.se> <40B47557.2000400@RedHat.com> <40B4761A.6020705@byggmek.lth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSyyL-0000I3-2N
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 07:01:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BSyyK-000843-Kb
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 07:01:32 -0700
To: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
In-Reply-To: <40B4761A.6020705@byggmek.lth.se>
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



Jonas Lindemann wrote:

> Steve Dickson wrote:
>
>> So are you saying that the client has the directory mounted and then
>> this special service runs (on the server) setting the executable bit 
>> on test.sh
>> but the client never sees that bit being set?
>
> The service runs on the client, and does not see this bit when queried.

hmm... so "chmod 700 test.sh ; ls -l test.sh" shows the
file being set to the 0600 mode... with all changes being
made from the client... Could you possibly make a compressed
ethereal trace of this phenomenon available?

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
