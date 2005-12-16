From: Neil Brown <neilb@suse.de>
Subject: Re: Re: An interesting performance thing ?
Date: Fri, 16 Dec 2005 12:25:57 +1100
Message-ID: <17314.6053.665428.83930@cse.unsw.edu.au>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
	<17312.39940.985507.704832@cse.unsw.edu.au>
	<43A0A0D5.4040804@citi.umich.edu>
	<018401c60108$c9477f30$1500000a@americas.hpqcorp.net>
	<17312.45710.867019.969182@cse.unsw.edu.au>
	<20051215023256.GA22951@fieldses.org>
	<020a01c60133$3d8fc530$1500000a@americas.hpqcorp.net>
	<20051215144901.GD14973@fieldses.org>
	<02f001c6018d$56b31030$1500000a@americas.hpqcorp.net>
	<20051215161431.GA21043@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Iozone <capps@iozone.org>, cel@citi.umich.edu,
	wli@holomorphy.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1En4MY-00013D-P2
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 17:26:22 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1En4MX-0002Qf-9V
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 17:26:22 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Thursday December 15
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

On Thursday December 15, bfields@fieldses.org wrote:
> I'm mainly curious how much effort it's worth expending on optimizing
> that hash.  If it turns out that even the current linear search isn't
> that expensive, then that's an argument against doing any more
> optimizing (beyond just fixing the current obvious problem).
> 

Thinking a bit more about this, a very suitable hash to produce 8 bits
from an IPv4 address would be to xor all the bytes together:
       hash = addr ^ (addr>>16);
       hash = (hash ^ (hash>>8)) & 0xff;

I think this would have good properties on any natural set of IP
addresses.

I'd still prefer to use a good general purpose hash function because
it is conceptually simpler.  But when one isn't available....

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
