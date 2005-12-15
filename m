From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: Error 512
Date: Wed, 14 Dec 2005 20:54:06 -0500 (EST)
Message-ID: <Pine.LNX.4.62.0512142052290.6445@chaos.egr.duke.edu>
References: <Pine.LNX.4.62.0512141521150.5180@chaos.egr.duke.edu>
 <1134601986.13707.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmiJz-0005RK-Hu
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 17:54:15 -0800
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmiJx-0004aQ-Ou
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 17:54:15 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134601986.13707.12.camel@lade.trondhjem.org>
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

On Wed, 14 Dec 2005 at 6:13pm, Trond Myklebust wrote

> On Wed, 2005-12-14 at 15:42 -0500, Joshua Baker-LePain wrote:
>> I'm still seeing a moderate number of errors like this on clients (both
>> centos-3 and centos-4) connected to my centos-4 servers:
>>
>> RPC: error 512 connecting to server $HOSTNAME
>> nfs_statfs: statfs error = 512
>>
>> associated with mounted FSs becoming unavailable for periods of time (not
>> sure exactly how long, but on the order of 10-15 minutes).  What exactly
>> is error 512, and where does it point me to for the purposes of fixing
>> this?
>
> Error 512 is ERESTARTSYS. It means you interrupted the RPC call...
>
> There is a patch going in to 2.6.16 that will remove that error message.

Ah, OK.  So you're saying I need to find out why the server is waiting 
10+ minutes to respond to the client's request(s).  *sigh*

Thanks.

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
