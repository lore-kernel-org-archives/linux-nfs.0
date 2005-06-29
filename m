From: Anthony Howe <ahowe_ca@yahoo.ca>
Subject: RE: slow file opens on nfs mount across high-latency network
Date: Wed, 29 Jun 2005 06:43:50 -0700
Message-ID: <000a01c57cb0$954c48a0$7101a8c0@orthanc>
References: <42C2950C.2070705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dncr7-0007Lq-P3
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 06:43:57 -0700
Received: from shawidc-mo1.cg.shawcable.net ([24.71.223.10] helo=pd2mo3so.prod.shaw.ca)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Dncr7-0004kn-CB
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 06:43:57 -0700
Received: from pd3mr4so.prod.shaw.ca
 (pd3mr4so-qfe3.prod.shaw.ca [10.0.141.180]) by l-daemon
 (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0IIU00EDHM52E110@l-daemon> for nfs@lists.sourceforge.net; Wed,
 29 Jun 2005 07:43:50 -0600 (MDT)
Received: from pn2ml2so.prod.shaw.ca ([10.0.121.146])
 by pd3mr4so.prod.shaw.ca (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar
 15 2004)) with ESMTP id <0IIU009ZZM520EE0@pd3mr4so.prod.shaw.ca> for
 nfs@lists.sourceforge.net; Wed, 29 Jun 2005 07:43:50 -0600 (MDT)
Received: from orthanc (S010600055dfdd2ca.gv.shawcable.net [24.69.124.240])
 by l-daemon (iPlanet Messaging Server 5.2 HotFix 1.18 (built Jul 28 2003))
 with ESMTP id <0IIU002K8M51EP@l-daemon> for nfs@lists.sourceforge.net; Wed,
 29 Jun 2005 07:43:50 -0600 (MDT)
In-reply-to: <42C2950C.2070705@redhat.com>
To: 'Peter Staubach' <staubach@redhat.com>,
	'Neil Horman' <nhorman@redhat.com>
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

>Neil Horman wrote:
>
>>On Tue, Jun 28, 2005 at 11:30:17AM -0400, Anthony Howe wrote:
>>  
>>
>>>I have searched through the mail lists and google and
>>>have not found material describing the nfs file open threshold effect 
>>>that I am experiencing.
>>>
>>>I have been experimenting with opening files on NFS
>>>mounts over varying network latencies.  I notice that
>>>there seems to be a threshold on the number of
>>>concurrent nfs file opens as network latency
>>>increases.  Up to and including the threshold, nfs
>>>file open performance is fine.  After the threshold of concurrent 
>>>opens, performance degrades at a linear rate.
>>>
>>>For example, the graph in the attached files shows
>>>this threshold effect for various network latencies:
>>>- 0ms network latency - no max limit
>>>- 20ms network latency - 40 maximum concurrent opens
>>>- 40ms network latency - 20 maximum concurrent opens
>>>- 80ms network latency - 15 maximum concurrent opens
>>>- 120ms network latency - 5 maximum concurrent opens
>>>
>>>What would cause this "hockey stick" threshold effect
>>>shown in the attached file?
>>>Are there any settings that would change this effect?
>>>
>>>Here are the stats of my experiment:
>>>- testing using Redhat Enterprise AS servers V3
>>>connected via a 100Mbps switch
>>>- inserting latency with nist net
>>>- experiment process spawns X number of threads set to
>>>each open a file on an NFS mount, the time taken for
>>>each file open is recorded
>>>- adjusting rsize, wsize does not affect "hockey
>>>stick" threshold effect
>>>- adjusting /proc/sys/net/core/rmem* does not affect
>>>"hockey stick" threshold effect
>>>- adjusting number of nfsd processes does not affect
>>>"hockey stick" threshold effect
>>>
>>>Thanks in advance for any tips or directions where I
>>>can look for more information on this topic.
>>>
>>>Regards,
>>>
>>>Anthony Howe
>>>
>>>__________________________________________________
>>>Do You Yahoo!?
>>>Tired of spam?  Yahoo! Mail has the best spam protection around
>>>http://mail.yahoo.com 
>>>    
>>>
>>
>>
>>do you have tcpdumps taken at all these data points?  It kind of sounds 
>>to me like your getting a geared slowdown from additional congestion 
>>caused by rpc retransmits (i.e., on a high latency link, you'll wind up 
>>with more rpc retransmits, resulting in more congestion, resulting in 
>>more lost packets, resulting in more retransmits, etc.).
>>
>Some questions --
>
>These are mounts done using the NFSv3 protocol?  Over TCP or over UDP?
>
>Each thread is opening an independent file?  In independent directories or
in a common directory?
>
>    Thanx...
>
>       ps

We are using the NFSv3 protocol over TCP.  Here the options for both the
client and the server:

- client options "rw, noexec, nosuid, nodev, noatime, hard, intr,tcp"

- server options "rw, aysnc, wdelay, all_squash, root_squash,anonuid=500,
anongid=500"

Each thread is opening an independent file from the same common nfs
directory.  So 100 threads will mean 100 separate files will be created.

(I am going to do some tcpdumps to see if there are a buildup of rpc
retransmits)

Thanks,

Anthony



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
