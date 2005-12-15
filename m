From: "Iozone" <capps@iozone.org>
Subject: Re: Re: An interesting performance thing ?
Date: Wed, 14 Dec 2005 22:51:40 -0600
Message-ID: <020a01c60133$3d8fc530$1500000a@americas.hpqcorp.net>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
 <17312.39940.985507.704832@cse.unsw.edu.au> <43A0A0D5.4040804@citi.umich.edu>
 <018401c60108$c9477f30$1500000a@americas.hpqcorp.net>
 <17312.45710.867019.969182@cse.unsw.edu.au>
 <20051215023256.GA22951@fieldses.org>
Reply-To: "Iozone" <capps@iozone.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=iso-8859-1; reply-type=original
Cc: <cel@citi.umich.edu>, <wli@holomorphy.com>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eml5l-0008GP-5f
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 20:51:45 -0800
Received: from vms046pub.verizon.net ([206.46.252.46])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Eml5j-0002Gn-23
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 20:51:45 -0800
Received: from cappsnc ([71.96.135.143])
 by vms046.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0IRI00MDPW65ED25@vms046.mailsrvcs.net> for
 nfs@lists.sourceforge.net; Wed, 14 Dec 2005 22:51:42 -0600 (CST)
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Neil Brown" <neilb@suse.de>
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
To: "Neil Brown" <neilb@suse.de>
Cc: "Iozone" <capps@iozone.org>; <cel@citi.umich.edu>; <wli@holomorphy.com>; 
<nfs@lists.sourceforge.net>
Sent: Wednesday, December 14, 2005 8:32 PM
Subject: Re: [NFS] Re: An interesting performance thing ?


> On Thu, Dec 15, 2005 at 11:02:22AM +1100, Neil Brown wrote:
>> The trouble is that just because inet_lnaof makes the final hash
>> better for your mix of clients, that doesn't mean it won't make it
>> worse for someone else.  I admit that I cannot provide a like sample
>> mix of clients what would be worse with inet_lnaof, but that doesn't
>> mean they don't exist.
>
> It strikes me as extremely unlikely that any set of clients would have
> good variation in the *high* 13 bits of their IP addresses.
>
> In fact, in the common case the high 13 bits are probably completely
> constant.
>
> So for these architectures, the ip address lookup is probably usually
> degenerating to a linear search.  Since that lookup has to be performed
> on every rpc call, this is likely to be painful.
>
>> But I don't propose submitting it to Linus because - useful as it is -
>> it is simply wrong.  We need to fix that hash function, and this clear
>> problem is a good motivation to do that.
>
> It'd be worth checking whether other callers may be giving hash_long
> 32-bit inputs, since they might have similar problems.
>
> --b.
>

Bruce,

        One of the interesting things I noticed is that the general
    purpose hash_long() function may not be as optimal
    as a more focused hash_IP_addr() function might be,
    even if GOLDEN were GOLDEN :-) And, trying
    to smash 128 bit IPV6 addresses into a 8 bit hash
    value, that is somehow uniformly distributed, well,
    that's going to be quite a neat trick, and making it
    work for 32 bit, 64, and 128 bit objects, with uniform
    distribution over a variable number of output bits,
    is approaching magical.

        If one knows that the frequency of change of the
    bytes in the value, to be hashed, then a more targeted hash
    algorithm might take advantage of this pre-knowledge
    to contribute to the uniformity of the output hash.

    With respect to IPV4 addresses:

        aa.bb.cc.dd

    where dd changes the fastest, then cc, then bb, then aa.

    Thus the bits in dd are more interesting than the bits in
    cc, and the bits in cc are more interesting than in bb,
    and the bits in aa are pretty much static.
        (Not many NFS servers have clients that span
         large numbers of class "A networks :-)

    Hash_long(), being general purpose, could not take
    advantage of this, but something else might ?

    Bruce:  You noticed that my suggestion of inet_lnaof()
    didn't cure the hash_long limitations, just moved the
    frequently modified bits into an active region of the
    hash algorithm :-) Sort of like tricking hash_long() into
    a performing like a more targeted hash, just for IPV4
    address ranges that an NFS server would be most likely
    to see....... :-)

    You did raise an interesting question...Are other 32 bit values
    being handed to hash_long() ? Good question. Wonder
    if these callers also have particular needs that might
    be addressed by a targeted hash algorithm ? Hmmmmm...

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
