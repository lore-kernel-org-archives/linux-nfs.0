From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: An interesting performance thing ?
Date: Wed, 14 Dec 2005 21:22:10 -0500
Message-ID: <20051215022210.GB21176@fieldses.org>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emil7-0007Qn-PE
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 18:22:17 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emil5-0001W9-DU
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 18:22:17 -0800
To: Iozone <capps@iozone.org>
In-Reply-To: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
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

On Wed, Dec 14, 2005 at 12:22:38PM -0600, Iozone wrote:
>     Then the hash_long function would have done a nice job.  Since
>     one is not converting the network neutral IP address into a 
>     host binary format, here is an example of the hash distribution
>     that, I believe via experimentation, is currently being seen on 
>     Little Endian 64 Bit systems....

A little bit of fiddling about with pencil and paper shows what's
happening:  suppose longs are 64 bits and let x be a long.  Then
hash_long operates on x by multiplying it by

	 1 - 2^18 - 2^51 + 2^54 - 2^57 + 2^61 + 2^63

and then taking the high bits.

You can think of that as adding and subtracting a bunch of left-shifts.
Note that the last four terms are all shifts by at least 51 bits, so
wipe out all but the lowest 13 bits.  So if those low 13 bits are all
constant, then the only variation is from multiplication by (1 - 2^18).
But if the input is small (say the top 32 bits are all zero...) then
multiplying by (1 - 2^18) doesn't affect the high bits of the output at
all.

So in our case, where the 32 high bits are zero and we're only asking
for the top 8 bits, it looks like all but the bottom 13 bits of x (the
top 13 bits of the IP address) are ignored.

--b.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
