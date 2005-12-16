From: "Iozone" <capps@iozone.org>
Subject: Re: Re: An interesting performance thing ?
Date: Thu, 15 Dec 2005 21:59:10 -0600
Message-ID: <046b01c601f5$128c55c0$1500000a@americas.hpqcorp.net>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
 <17312.39940.985507.704832@cse.unsw.edu.au>	<43A0A0D5.4040804@citi.umich.edu>
 <018401c60108$c9477f30$1500000a@americas.hpqcorp.net>
 <17312.45710.867019.969182@cse.unsw.edu.au>
 <20051215023256.GA22951@fieldses.org>
 <020a01c60133$3d8fc530$1500000a@americas.hpqcorp.net>
 <20051215144901.GD14973@fieldses.org>
 <02f001c6018d$56b31030$1500000a@americas.hpqcorp.net>
 <20051215161431.GA21043@fieldses.org> <17314.6053.665428.83930@cse.unsw.edu.au>
Reply-To: "Iozone" <capps@iozone.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=iso-8859-1; reply-type=original
Cc: <cel@citi.umich.edu>, <wli@holomorphy.com>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1En6kU-0002j3-4D
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 19:59:14 -0800
Received: from vms042pub.verizon.net ([206.46.252.42])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1En6kU-0002GN-3E
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 19:59:14 -0800
Received: from cappsnc ([71.96.135.143])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0IRK00BOQOEMVBX8@vms042.mailsrvcs.net> for
 nfs@lists.sourceforge.net; Thu, 15 Dec 2005 21:59:12 -0600 (CST)
To: "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>
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
From: "Neil Brown" <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Iozone" <capps@iozone.org>; <cel@citi.umich.edu>; <wli@holomorphy.com>; 
<nfs@lists.sourceforge.net>
Sent: Thursday, December 15, 2005 7:25 PM
Subject: Re: [NFS] Re: An interesting performance thing ?


> On Thursday December 15, bfields@fieldses.org wrote:
>> I'm mainly curious how much effort it's worth expending on optimizing
>> that hash.  If it turns out that even the current linear search isn't
>> that expensive, then that's an argument against doing any more
>> optimizing (beyond just fixing the current obvious problem).
>>
>
> Thinking a bit more about this, a very suitable hash to produce 8 bits
> from an IPv4 address would be to xor all the bytes together:
>       hash = addr ^ (addr>>16);
>       hash = (hash ^ (hash>>8)) & 0xff;
>
> I think this would have good properties on any natural set of IP
> addresses.
>
> I'd still prefer to use a good general purpose hash function because
> it is conceptually simpler.  But when one isn't available....
>
> NeilBrown
>

Neil,

        I think we're in phase :-)  I too was thinking of
    something much simpler and faster, that took advantage
    of the pre-knowledge of variably of the input, the
    needed size, and distribution of the hash output.

    This approach has some interesting benefits:

    1) Runs faster, and consumes far fewer CPU cycles.
        Zero multiples, or golden primes, and a bunch fewer
        other instructions.
    2) Does a better distribution than any general purpose hash function.
    3) Can easily be adapted for IPV6
    4) Needs far less testing, than a one fits all model.
    5) Can be implemented quickly, easily, and has low risk
        of affecting un-related subsystems.
    6) Will not need a PHD (strong in number theory) to understand that
        it's actually doing a good job.

        Don't get me wrong, I still see a need for a generalized hash
    algorithm that needs primes, and heavy magic. Its needed for
    nodalization with unpredictable invariant bit pattern inputs (due to 
compiler
    alignments of native data types, and structure alignments, on pointers)
    and other non-predictive input data sets. But with IP addresses, the
    natural distribution does not have the same issues, and can
    be solved much more effectively, and efficiently. As is
    demonstrated so well, by you, above :-)

    Is it too late to place an order for one of these for Christmas ?

Enjoy,
Don Capps

P.S. If you go with your algorithm above, I'll concede the
        need for inet_lnaof(s_addr)  The folding and XORs
        work fine on either native or network neutral formats.
         :-)






-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
