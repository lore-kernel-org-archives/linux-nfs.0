From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Tue, 13 Jul 2004 16:16:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40F4433A.5090708@RedHat.com>
References: <40F3D483.8020507@RedHat.com> <20040713143044.GA3023@fieldses.org> <40F3FAD8.7090707@RedHat.com> <20040713151759.GC3023@fieldses.org> <20040713180108.GF3023@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BkTi6-0000vp-QG
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 13:17:06 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BkTi6-0005nI-BQ
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 13:17:06 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040713180108.GF3023@fieldses.org>
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

J. Bruce Fields wrote:

>On Tue, Jul 13, 2004 at 11:17:59AM -0400, J. Bruce Fields wrote:
>  
>
>>On Tue, Jul 13, 2004 at 11:08:08AM -0400, Steve Dickson wrote:
>>    
>>
>>>Starting up a test run, zeroing out the stats give you a very clear
>>>picture of what exactly is going on...
>>>      
>>>
>>But you could exactly the same thing by recording the values at the
>>beginning of the test run and then subtracting.  In practice this is
>>likely to be annoying, so you'd want to write utilities that did this
>>for you, like say
>>    
>>
IMHO,  its much simpler, easier and less error prone to zero them out 
than to make nfsstat
take samples then calculate the differences... I just think that a bit 
over nfsstat's head...

>>checkpoint_stats stats.txt
>>display_stats --since stats.txt
>>
>>That'd do what you want, right?
>>    
>>
>
>The problem I have, by the way, is that zeroing is going to cause
>confusing problems whenever there are two simultaneous attempts to
>collect statistics.
>
>For example, imagine that your NFS server has a persistent
>performance-monitoring daemon that checks the statistics every now and
>then and emails the adminstrator a summary once a week.
>
>Then imagine that one day you have a problem with the server, so you log
>in and do a quick check of some statistics, zeroing them in the process.
>Now the daemon has no more hope of getting its numbers right.  Murphy's
>law being what it is, you and the adminstrator that gets the summary
>email are probably different people, and by the time he/she gets the
>very odd-looking end-of-week report you've forgotten that you zeroed the
>statistics once.  Head-scratching ensues.
>
>Writing a script to do the subtraction is just as simple and avoids any
>such problems.
>  
>
Hang on.... Lets keep this in prospective....  Stats that  calculate bit 
rates,latencies and such (Like the ones
in Chuck's per-mount patchs) should not be zeroed out, since it simply 
does not make sense, due to
the collection issues you've outline... but I contend that the current 
nfsd/rpc stats simply aren't
these type of stats... these are simple activity counters that let you 
know what (if anything) is
happening... I think it would be a very difficult task to try to used 
these counts in any long
term analysis... I just don't think they recored the right type of 
information for that....

but... I do think allowing them to be reinitialized (maybe that's better 
term 8-)) makes
them much more useful than they currently are... TBL, when was the last time
anybody looked at these stats because they are basically unmanageable,
having the ability to zero them out, make them much more useful (imho)....

SteveD.


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
