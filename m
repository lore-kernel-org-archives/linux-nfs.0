From: "Iozone" <capps@iozone.org>
Subject: Re: Re: An interesting performance thing ?
Date: Thu, 15 Dec 2005 09:36:37 -0600
Message-ID: <02f001c6018d$56b31030$1500000a@americas.hpqcorp.net>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
 <17312.39940.985507.704832@cse.unsw.edu.au> <43A0A0D5.4040804@citi.umich.edu>
 <018401c60108$c9477f30$1500000a@americas.hpqcorp.net>
 <17312.45710.867019.969182@cse.unsw.edu.au>
 <20051215023256.GA22951@fieldses.org>
 <020a01c60133$3d8fc530$1500000a@americas.hpqcorp.net>
 <20051215144901.GD14973@fieldses.org>
Reply-To: "Iozone" <capps@iozone.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=iso-8859-1; reply-type=original
Cc: "Neil Brown" <neilb@suse.de>, <cel@citi.umich.edu>,
	<wli@holomorphy.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmvA3-0007dR-4y
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 07:36:51 -0800
Received: from vms040pub.verizon.net ([206.46.252.40])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Emv9y-0007dh-Up
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 07:36:51 -0800
Received: from cappsnc ([71.96.135.143])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0IRJ002HIQ114T10@vms040.mailsrvcs.net> for
 nfs@lists.sourceforge.net; Thu, 15 Dec 2005 09:36:40 -0600 (CST)
To: "J. Bruce Fields" <bfields@fieldses.org>
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


----- Original Message ----- 
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Iozone" <capps@iozone.org>
Cc: "Neil Brown" <neilb@suse.de>; <cel@citi.umich.edu>; 
<wli@holomorphy.com>; <nfs@lists.sourceforge.net>
Sent: Thursday, December 15, 2005 8:49 AM
Subject: Re: [NFS] Re: An interesting performance thing ?


> On Wed, Dec 14, 2005 at 10:51:40PM -0600, Iozone wrote:
>>        One of the interesting things I noticed is that the general
>>    purpose hash_long() function may not be as optimal
>>    as a more focused hash_IP_addr() function might be,
>>    even if GOLDEN were GOLDEN :-) And, trying
>>    to smash 128 bit IPV6 addresses into a 8 bit hash
>>    value, that is somehow uniformly distributed, well,
>>    that's going to be quite a neat trick, and making it
>>    work for 32 bit, 64, and 128 bit objects, with uniform
>>    distribution over a variable number of output bits,
>>    is approaching magical.
>
> I'm not so pessimistic, but I'm also not expert enough about hash
> functions to know how much magic is reasonable to expect out of a good
> one.  Time to pull out Knuth, maybe.
>
> There might also be an argument for experimenting with different data
> structures.  I'd expect high temporal locality--in typical situations a
> server with lots of clients may have only a few that are active at a
> particular time--so one of those balanced trees that migrates recently
> looked-up items to the top might be helpful.
>
> Aside from seeing the race condition triggered, have you done any
> profiling to make sure this is actually a big problem, even with the
> current worst-case linear-search behaviour?
>
> --b.
>

Bruce,

        I have not done a comprehensive profile analysis, but
    have some data I can share.

        At the time when the race caused the system to crash,
    there were 47 NFS clients currently all stacked up
    on one queue. No other queues had any items due
    to the fact that the hash_long function had placed
    all clients on a single queue.
        With the current behavior of hash_long, one
    can reasonably expect queue depths of 127 items
    per queue, (see earlier post demonstrating the hash distribution
    over a block of IP addresses where low order byte is
    monotonimically incremented) and very few queues to be
    active.
        With IP_HASHBITS = 8, there were 256 queues,
    but only one was active. If the hash distribution were
    uniform, then the queue depth could have been 1 (one)
    but instead is a linear search of a relatively large number
    of items.

    Does that help ?

Enjoy,
Don Capps


 




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
