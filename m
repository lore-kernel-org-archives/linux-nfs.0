From: Hugh Caley <hcaley@plasmabat.com>
Subject: Re: Performance Difference Between Linux NFS Server and Netapp
Date: Thu, 14 Jul 2005 13:41:02 -0700
Message-ID: <42D6CDDE.90703@plasmabat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DtAW0-0001jV-SW
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 13:41:04 -0700
Received: from firewall.neomorphic.com ([205.217.46.68] helo=roma.ev.affymetrix.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DtAVz-0006ig-Iw
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 13:41:05 -0700
Received: from [10.82.12.54] (puglia.ev.affymetrix.com [10.82.12.54])
	by roma.ev.affymetrix.com (8.11.6/8.11.6) with ESMTP id j6EKf2H31746
	for <nfs@lists.sourceforge.net>; Thu, 14 Jul 2005 13:41:02 -0700
To: nfs@lists.sourceforge.net
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

Thank you!  Just the sort of thing I'm looking for ...

Hugh

>From: Chris Penney <cpenney@gmail.com>
>Reply-To: penney@msu.edu
>To: nfs@lists.sourceforge.net
>Subject: Re: [NFS] Performance Difference Between Linux NFS Server and Netapp
>
>
>On 7/14/05, Hugh Caley <hcaley@plasmabat.com> wrote:=20
>  
>
>>>=20
>>> A valid point, of course, but I don't think I'm actually expecting a
>>> single NFSd to act like an expensive Netapp. I do think that wondering
>>> why the Netapp is twice as fast for a sequential write is a valid
>>> question, even if the OS and NFS server subsystem are free. I was kind
>>> of hoping someone would just say "you're getting what you should expect
>>> to get" or "wow, that's slow, try this and this and this".
>>    
>>
>
> You referenced that you were getting 300 megabits (or 37MB/s). I have=20
>several SLES 9 nfs servers (using self compiled 2.6.11.5
><http://2.6.11.5>kernel) running on IBM x345 hardware (dual cpu pentum
>4, 2gb ram, dual
>qlogic hbas) connected to a single LSI storage array that presents four lun=
>s=20 ...
>

-- 
Whatsoever hath no fins nor scales in the waters, that shall be an abomination unto you. - Leviticus 11:9-12 
http://godhatesshrimp.com
Hugh Caley hcaley@plasmabat.com



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
