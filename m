From: Neil Brown <neilb@suse.de>
Subject: Re: Re: An interesting performance thing ?
Date: Thu, 15 Dec 2005 11:57:36 +1100
Message-ID: <17312.49024.378295.414582@cse.unsw.edu.au>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
	<17312.39940.985507.704832@cse.unsw.edu.au>
	<43A0A0D5.4040804@citi.umich.edu>
	<018401c60108$c9477f30$1500000a@americas.hpqcorp.net>
	<17312.45710.867019.969182@cse.unsw.edu.au>
	<43A0BC49.3070604@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Iozone <capps@iozone.org>, wli@holomorphy.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmhRP-0000US-HK
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 16:57:51 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmhRO-0007Tr-CG
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 16:57:51 -0800
To: cel@citi.umich.edu
In-Reply-To: message from Chuck Lever on Wednesday December 14
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

On Wednesday December 14, cel@citi.umich.edu wrote:
> 
> we might also think a little bit of the future (IPv6).
> 
> IPv6 addresses are larger than IPv4 addresses, so they will need their 
> own hash function, *or* we will have to design a reasonable hash 
> function for variably-sized addresses now, which seems like a harder 
> problem.

A hash for a variable sized value isn't really a problem.
Just break it into small bits and compose the hashes, similar
to what hash_str in include/linux/sunrpc/svcauth.h does.

A good question is:  Do we ever need more than 4 bytes of hash
value?
We wouldn't for hash tables, but they may well be other uses of
hashes.

If we don't then a function that maps and arbitrary mem buffer into
a u32 would be suitable general for all uses or all architectures,
though some special cases like 4byte and 8byte inputs could probably
be optimised sensibly.

 I suspect the function given in
   http://burtleburtle.net/bob/hash/evahash.html

my really be a good choice.  
It does about 40 add/subtracts for each 4bytes, but seems to have good
properties.
(Hmm.. that is probably similar to a constant 32bit multiply, but
 maybe the current code with a better non-sparse prime is just as
 good).

NeilBrown



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
