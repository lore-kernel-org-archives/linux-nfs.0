From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 3/4 Revised] NLM - kernel lockd-statd changes
Date: Tue, 17 Apr 2007 11:09:41 -0400
Message-ID: <4624E335.7050907@redhat.com>
References: <46156FA0.4030506@redhat.com> <200704171352.27620.okir@lst.de>
	<4624CA93.4040307@redhat.com> <200704171651.36497.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, cluster-devel@redhat.com,
	Lon Hohberger <lhh@redhat.com>, nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdpfD-0000bp-An
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 08:32:15 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hdpf9-0006ja-Lw
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 08:32:17 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1Hdpf3-0006xe-AL
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 08:32:06 -0700
In-Reply-To: <200704171651.36497.okir@lst.de>
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

Olaf Kirch wrote:
> On Tuesday 17 April 2007 15:24, Wendy Cheng wrote:
>   
>>> I think in term of correctness, it's better to send an SM_NOTIFY
>>> for each IP associated with such a set, anyway.
>>>   
>>>       
>> That's exactly what we have been proposing... :) .. We'll rely heavily 
>> on HA callout program to tell us which client uses which (server) 
>> floating IP. 
>>     
>
> Correct me if I'm wrong, but it seems your patch records every IP
> used by the client, rather than the *all* the IPs related to the set of
> file systems being moved. So if there are several IPs for this set, you
> will end up sending notifications only from those the client happened
> to have talked to.
>   

Yes. Then why should we SM_NOTIFY the clients that do not have the 
associated locks (and introducing more possible reclaiming delay) ? Be 
aware that failover normally has timing constraints - it needs to get 
finished within a sensible time interval.

-- Wendy
> My point was, you move a set of file systems A, B and C, with
> IPs X, Y, Z. You know what the addresses are, so from a
> robustness point of view your best bet is to send SM_NOTIFY
> messages from IPs X, Y, Z, regardless of whether the client has
> been talking to all of them, or just one.
>
> Olaf
>   


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
