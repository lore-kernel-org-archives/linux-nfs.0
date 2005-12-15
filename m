From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: Error 512
Date: Thu, 15 Dec 2005 14:40:15 -0500 (EST)
Message-ID: <Pine.LNX.4.62.0512151439420.5180@chaos.egr.duke.edu>
References: <Pine.LNX.4.62.0512141521150.5180@chaos.egr.duke.edu>
 <1134601986.13707.12.camel@lade.trondhjem.org>
 <Pine.LNX.4.62.0512142052290.6445@chaos.egr.duke.edu>
 <1134612343.13707.20.camel@lade.trondhjem.org>
 <Pine.LNX.4.62.0512151405060.5180@chaos.egr.duke.edu>
 <1134675422.7956.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emyxl-0000bh-9f
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 11:40:25 -0800
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emyxk-00045E-1Q
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 11:40:25 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134675422.7956.12.camel@lade.trondhjem.org>
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

On Thu, 15 Dec 2005 at 2:37pm, Trond Myklebust wrote

> On Thu, 2005-12-15 at 14:05 -0500, Joshua Baker-LePain wrote:
>> On Wed, 14 Dec 2005 at 9:05pm, Trond Myklebust wrote
>>
>>> On Wed, 2005-12-14 at 20:54 -0500, Joshua Baker-LePain wrote:
>>
>>>> Ah, OK.  So you're saying I need to find out why the server is waiting
>>>> 10+ minutes to respond to the client's request(s).  *sigh*
>>>
>>> Yep. If you can send us a tcpdump, then that might help...
>>
>> http://biomechanics.bme.duke.edu/~jlb/nfshang
>>
>
> It looks like the client is looping while trying to connect to the
> server. The server appears to be ACKing the connection attempt, but that
> is where it stops.
>
> I assume this tcpdump was taken on the server? If so, it might be
> interesting to look at what the client is seeing.

Actually, that was on the client.  Would it be helpful to look at it from 
the server side?

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
