From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: An interesting performance thing ?
Date: Wed, 14 Dec 2005 21:32:56 -0500
Message-ID: <20051215023256.GA22951@fieldses.org>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net> <17312.39940.985507.704832@cse.unsw.edu.au> <43A0A0D5.4040804@citi.umich.edu> <018401c60108$c9477f30$1500000a@americas.hpqcorp.net> <17312.45710.867019.969182@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Iozone <capps@iozone.org>, cel@citi.umich.edu,
	wli@holomorphy.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emivc-00084A-Qm
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 18:33:08 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emivc-0005BK-Io
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 18:33:08 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17312.45710.867019.969182@cse.unsw.edu.au>
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

On Thu, Dec 15, 2005 at 11:02:22AM +1100, Neil Brown wrote:
> The trouble is that just because inet_lnaof makes the final hash
> better for your mix of clients, that doesn't mean it won't make it
> worse for someone else.  I admit that I cannot provide a like sample
> mix of clients what would be worse with inet_lnaof, but that doesn't
> mean they don't exist.

It strikes me as extremely unlikely that any set of clients would have
good variation in the *high* 13 bits of their IP addresses.

In fact, in the common case the high 13 bits are probably completely
constant.

So for these architectures, the ip address lookup is probably usually
degenerating to a linear search.  Since that lookup has to be performed
on every rpc call, this is likely to be painful.

> But I don't propose submitting it to Linus because - useful as it is -
> it is simply wrong.  We need to fix that hash function, and this clear
> problem is a good motivation to do that.

It'd be worth checking whether other callers may be giving hash_long
32-bit inputs, since they might have similar problems.

--b.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
