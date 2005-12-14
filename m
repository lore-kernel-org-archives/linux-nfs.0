From: "Iozone" <capps@iozone.org>
Subject: Re: An interesting performance thing ?
Date: Wed, 14 Dec 2005 17:47:47 -0600
Message-ID: <018401c60108$c9477f30$1500000a@americas.hpqcorp.net>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
 <17312.39940.985507.704832@cse.unsw.edu.au> <43A0A0D5.4040804@citi.umich.edu>
Reply-To: "Iozone" <capps@iozone.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=iso-8859-1; reply-type=original
Cc: <wli@holomorphy.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmgLh-0004PL-8f
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 15:47:53 -0800
Received: from vms042pub.verizon.net ([206.46.252.42])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EmgLh-0004Mi-53
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 15:47:53 -0800
Received: from cappsnc ([71.96.135.143])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0IRI00K7XI3N2RS1@vms042.mailsrvcs.net> for
 nfs@lists.sourceforge.net; Wed, 14 Dec 2005 17:47:48 -0600 (CST)
To: <cel@citi.umich.edu>, "Neil Brown" <neilb@suse.de>
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
From: "Chuck Lever" <cel@citi.umich.edu>
To: "Neil Brown" <neilb@suse.de>
Cc: "Iozone" <capps@iozone.org>; <wli@holomorphy.com>; 
<nfs@lists.sourceforge.net>
Sent: Wednesday, December 14, 2005 4:46 PM
Subject: Re: An interesting performance thing ?


> Neil Brown wrote:
>> William, Chunk:  Any suggestions on whether a straight multiply would
>> be too expensive, or what else we could do to make hash_long both fast
>> and effective?
>
> my original proposal was a hash function which computed the index by a
> single multiplication with a large prime number.  i was told that
> multiplication was too expensive, especially on older platforms, so the
> existing computation took its place.  but i don't think anyone ever did
> any real studies.  i can't imagine that multiplication would be worse
> than extra elements in a hash chain, especially on modern CPU 
> architectures.
>

Neil,

    In a perfect world, a perfect hash would be ideal...but,

    1. It is fairly normal practice for code to call inet_lnaof( in_addr )
        so that the host native format is used by the host. Just
        grabbing s_addr is a bit odd.
    2. Simply adding the inet_lnaof( in_addr ) would do nice
        things with the existing hash algorithm, for CDIR allocated
        monotonically incremented IP address spaces.
    3. Gosh, it seems like a pretty easy and safe change.

        I think I understand Neil's position. If one hands a 64 bit
    opaque object to a hash function, it should do a better
    job of distribution, so who cares if it was in the native
    format or not.  Ok..  But, given 1->3 above, it seems
    like there might be a lower risk, less controversial, solution
    for the immediate future, and permit folks to do a study
    while the world goes on its happy way :-)

    Thanks again for being kind to new kid tossing
    spitballs :-)

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
