From: Neil Brown <neilb@suse.de>
Subject: Re: An interesting performance thing ?
Date: Thu, 15 Dec 2005 11:02:22 +1100
Message-ID: <17312.45710.867019.969182@cse.unsw.edu.au>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
	<17312.39940.985507.704832@cse.unsw.edu.au>
	<43A0A0D5.4040804@citi.umich.edu>
	<018401c60108$c9477f30$1500000a@americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <cel@citi.umich.edu>, <wli@holomorphy.com>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmgZw-0005Fb-RO
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 16:02:36 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmgZv-0005nt-5F
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 16:02:36 -0800
To: "Iozone" <capps@iozone.org>
In-Reply-To: message from Iozone on Wednesday December 14
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

On Wednesday December 14, capps@iozone.org wrote:
> 
> Neil,
> 
>     In a perfect world, a perfect hash would be ideal...but,
> 
>     1. It is fairly normal practice for code to call inet_lnaof( in_addr )
>         so that the host native format is used by the host. Just
>         grabbing s_addr is a bit odd.
>     2. Simply adding the inet_lnaof( in_addr ) would do nice
>         things with the existing hash algorithm, for CDIR allocated
>         monotonically incremented IP address spaces.
>     3. Gosh, it seems like a pretty easy and safe change.
> 
>         I think I understand Neil's position. If one hands a 64 bit
>     opaque object to a hash function, it should do a better
>     job of distribution, so who cares if it was in the native
>     format or not.  Ok..  But, given 1->3 above, it seems
>     like there might be a lower risk, less controversial, solution
>     for the immediate future, and permit folks to do a study
>     while the world goes on its happy way :-)

The trouble is that just because inet_lnaof makes the final hash
better for your mix of clients, that doesn't mean it won't make it
worse for someone else.  I admit that I cannot provide a like sample
mix of clients what would be worse with inet_lnaof, but that doesn't
mean they don't exist.

If the only symptom that has been identified is that it makes a
locking race easier to hit, then the obvious first solution is to fix
that locking race, and I believe such a fix is available.

If anyone were experiencing a measurable slowness due to the bad hash,
then I would have not problem suggesting they try the inet_lnaof
solution.

But I don't propose submitting it to Linus because - useful as it is -
it is simply wrong.
We need to fix that hash function, and this clear problem is a good
motivation to do that.

Or to put it another way, I don't think it is clear that we *need* a
solution for the immediate future.

NeilBrown




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
