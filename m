From: Hugh Caley <hcaley@plasmabat.com>
Subject: Re: Performance Difference Between Linux NFS Server and Netapp
Date: Thu, 14 Jul 2005 11:21:28 -0700
Message-ID: <42D6AD28.3030204@plasmabat.com>
References: <42D2F8F9.4010304@plasmabat.com> <Pine.SOC.4.61.0507141312090.9294@tea.blinkenlights.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt8L7-00047W-7O
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 11:21:41 -0700
Received: from firewall.neomorphic.com ([205.217.46.68] helo=roma.ev.affymetrix.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Dt8L5-0001jl-PS
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 11:21:41 -0700
To: Sten Spans <sten@blinkenlights.nl>
In-Reply-To: <Pine.SOC.4.61.0507141312090.9294@tea.blinkenlights.nl>
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

Sten Spans wrote:

> On Mon, 11 Jul 2005, Hugh Caley wrote:
>
>> How does Netapp do it?  Don't suppose they'd tell me ...
>
>
> Quite simple really, you pay them loads of money, they
> give part of it to engineers doing work on nfs tuning.
>
> They generally have 3 performance advantages:
>
> - battery backed cache with full os support,
>   ...
>
> - special filesystem which allows writing data on any
>   ...

I actually don't think filesystem type is relevant to my question.  I 
tested this out pretty thoroughly with all the journaling filesystems 
available from the Fedora Core 2 kernels (Ext3, Reiser, XFS, JFS), and 
although Ext3 had by far the worst local performance, it's performance 
over NFS with my simple sequential write test was exactly the same as 
the others.  I mean, I'm talking about a single sequential write to a 
10-disk RAID5 attached with 2 Gb fibre channel; whichever file system I 
use on the RAID should be a whole lot faster than over NFS, and indeed 
they all are, Ext3 about 3 times, the others much more.

So, unless there are hooks between the filesystem and the NFSd that are 
not obvious to a user (and the fact that changing filesystems doesn't 
seem to make much difference seems to rule that out) and the fact that 
the NFS client seems capable of much better performance when used 
against a Netapp, it makes me wonder what's going on with the server 
portion.

> - Highly tuned nfs inplementation with dedicated operating system.
>
> The bruteforce linux approach is quite good for the money spent,
> but don't expect the features/performance of a way more expensive
> enterprise solution.
>
A valid point, of course, but I don't think I'm actually expecting a 
single NFSd to act like an expensive Netapp.  I do think that wondering 
why the Netapp is twice as fast for a sequential write is a valid 
question, even if the OS and NFS server subsystem are free.  I was kind 
of hoping someone would just say "you're getting what you should expect 
to get" or "wow, that's slow, try this and this and this".

And I did mention that moving to the Linux/NFS/Atabeast solution was 
quite a bit better than what we had before ;)  I'm not really 
complaining, just wondering here.

Hugh

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
