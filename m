From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 3/4 Revised] NLM - kernel lockd-statd changes
Date: Tue, 17 Apr 2007 09:24:35 -0400
Message-ID: <4624CA93.4040307@redhat.com>
References: <46156FA0.4030506@redhat.com>
	<17948.26876.426822.963222@notabene.brown>
	<20070413191615.GU1804@redhat.com> <200704171352.27620.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, cluster-devel@redhat.com,
	Lon Hohberger <lhh@redhat.com>, nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdoPN-0007Kv-I8
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 07:11:49 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdoPP-00074d-Qy
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 07:11:52 -0700
In-Reply-To: <200704171352.27620.okir@lst.de>
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
> On Friday 13 April 2007 21:16, Lon Hohberger wrote:
>   
>> The simplification here is a bit incorrect; we need to be able to handle
>> a given *set* of size >= 1 IPs which is paired with a *set* of size >= 1
>> of fsids.  The sets are not broken up (that is, we won't be moving 
>> file systems between IP addresses or vice-vers), but the number of
>> IPs:filesystems need not be 1:1.
>>
>>    * 1 file system, 1 ip address
>>    * 2 fs, 1 ip
>>    * 1 ip, 2 fs
>>    * 18 ip, 42 fs.
>>     
>
> So you move a bunch of file systems with a bunch of IPs, and that
> information is recorded somewhere. So if you know you're moving
> set X, which goes with IPs 1.2.3.4 and 1.2.3.5, you might as well
> send notifications from both these IPs to all clients having established
> locks on a file system from that set.
>
> I think in term of correctness, it's better to send an SM_NOTIFY
> for each IP associated with such a set, anyway.
>   

That's exactly what we have been proposing... :) .. We'll rely heavily 
on HA callout program to tell us which client uses which (server) 
floating IP. 
> To me, it seems the crucial point of information here when monitoring
> a client, is which file system (or set of file systems) the client has
> accessed.
>
>   
The summary will be sent out shortly ... sorry - it is a little bit 
behind schedules due to other issues.

-- Wendy


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
