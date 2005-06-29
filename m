From: Peter Staubach <staubach@redhat.com>
Subject: Re: slow file opens on nfs mount across high-latency network
Date: Wed, 29 Jun 2005 08:33:16 -0400
Message-ID: <42C2950C.2070705@redhat.com>
References: <20050628153017.23248.qmail@web21323.mail.yahoo.com> <20050629120445.GB6865@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Anthony Howe <ahowe_ca@yahoo.ca>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnboI-0003x9-6M
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 05:36:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DnboH-0006De-MW
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 05:36:58 -0700
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20050629120445.GB6865@hmsendeavour.rdu.redhat.com>
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

Neil Horman wrote:

>On Tue, Jun 28, 2005 at 11:30:17AM -0400, Anthony Howe wrote:
>  
>
>>I have searched through the mail lists and google and
>>have not found material describing the nfs file open
>>threshold effect that I am experiencing.  
>>
>>I have been experimenting with opening files on NFS
>>mounts over varying network latencies.  I notice that
>>there seems to be a threshold on the number of
>>concurrent nfs file opens as network latency
>>increases.  Up to and including the threshold, nfs
>>file open performance is fine.  After the threshold of
>>concurrent opens, performance degrades at a linear
>>rate.
>>
>>For example, the graph in the attached files shows
>>this threshold effect for various network latencies:
>>- 0ms network latency - no max limit
>>- 20ms network latency - 40 maximum concurrent opens
>>- 40ms network latency - 20 maximum concurrent opens
>>- 80ms network latency - 15 maximum concurrent opens
>>- 120ms network latency - 5 maximum concurrent opens
>>
>>What would cause this "hockey stick" threshold effect
>>shown in the attached file?
>>Are there any settings that would change this effect?
>>
>>Here are the stats of my experiment:
>>- testing using Redhat Enterprise AS servers V3
>>connected via a 100Mbps switch
>>- inserting latency with nist net
>>- experiment process spawns X number of threads set to
>>each open a file on an NFS mount, the time taken for
>>each file open is recorded
>>- adjusting rsize, wsize does not affect "hockey
>>stick" threshold effect
>>- adjusting /proc/sys/net/core/rmem* does not affect
>>"hockey stick" threshold effect
>>- adjusting number of nfsd processes does not affect 
>>"hockey stick" threshold effect
>>
>>Thanks in advance for any tips or directions where I
>>can look for more information on this topic.
>>
>>Regards,
>>
>>Anthony Howe
>>
>>__________________________________________________
>>Do You Yahoo!?
>>Tired of spam?  Yahoo! Mail has the best spam protection around 
>>http://mail.yahoo.com 
>>    
>>
>
>
>do you have tcpdumps taken at all these data points?  It kind of sounds to me
>like your getting a geared slowdown from additional congestion caused by rpc
>retransmits (i.e., on a high latency link, you'll wind up with more rpc
>retransmits, resulting in more congestion, resulting in more lost packets,
>resulting in more retransmits, etc.).
>
Some questions --

These are mounts done using the NFSv3 protocol?  Over TCP or over UDP?

Each thread is opening an independent file?  In independent directories
or in a common directory?

    Thanx...

       ps


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
