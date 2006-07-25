From: Paul Jimenez <pj@rgmadvisors.com>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Tue, 25 Jul 2006 09:49:44 -0500
Message-ID: <D29213A6-C328-4C88-8D6D-428F3FDF4F56@rgmadvisors.com>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
	<76bd70e30607250705h3e8c9eefjc794397e0c45a21b@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5OEa-0001WX-HT
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 07:50:08 -0700
Received: from colo-gw.rgmadvisors.com ([66.179.5.244]
	helo=mail.rgmadvisors.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5OEZ-00037o-RC
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 07:50:09 -0700
Received: from [10.0.4.219] (unknown [10.0.4.219])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	by mail.rgmadvisors.com (Postfix) with ESMTP id 0210920054E73
	for <nfs@lists.sourceforge.net>; Tue, 25 Jul 2006 09:50:04 -0500 (CDT)
In-Reply-To: <76bd70e30607250705h3e8c9eefjc794397e0c45a21b@mail.gmail.com>
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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


On Jul 25, 2006, at 9:05 AM, Chuck Lever wrote:

> On 7/25/06, Neil Brown <neilb@suse.de> wrote:
>> On Tuesday July 25, gnb@melbourne.sgi.com wrote:
>>> G'day,
>>>
>>>
>>> 001 knfsd: move tempsock aging to timer
>>
>> Looks good.
>> Has the subtle side effect that when we reach our limit on the number
>> of permitted tcp connections, the one that is discarded is the one
>> that has been open the longest, rather than the one that has be  
>> unused
>> for the longest.  The comment there says
>>                         /*
>>                          * Always select the oldest socket. It's  
>> not fair,
>>                          * but so is life
>>                          */
>> so I guess it is still correct ('oldest' is ambiguous).  The new
>> situation is probably equally (un)fair - would you agree?
>
> Ouch.  IMO this will penalize long-running workloads unnecessarily,
> and will likely be much more of a performance hit for such workloads
> than would be gained by improving the CPU cache behavior on the
> server.
>
> The previous algorithm (close the least recently used socket) is  
> more fair.

OTOH, getting rid of the longest-open one may have beneficial side  
effects
by restarting state associated with that long-running task from  
scratch, no?
Restarting long-running workloads with a clean slate every so often  
sounds
like a good idea to me - I'm confident that the performance and  
impact of
shorter lived connections is better understood than that of very long  
lived
connections, so given the choice I'd say go with restarting them  
every so
often.





-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
