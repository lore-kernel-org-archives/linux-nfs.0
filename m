From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: An interesting performance thing ?
Date: Thu, 15 Dec 2005 11:14:31 -0500
Message-ID: <20051215161431.GA21043@fieldses.org>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net> <17312.39940.985507.704832@cse.unsw.edu.au> <43A0A0D5.4040804@citi.umich.edu> <018401c60108$c9477f30$1500000a@americas.hpqcorp.net> <17312.45710.867019.969182@cse.unsw.edu.au> <20051215023256.GA22951@fieldses.org> <020a01c60133$3d8fc530$1500000a@americas.hpqcorp.net> <20051215144901.GD14973@fieldses.org> <02f001c6018d$56b31030$1500000a@americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, cel@citi.umich.edu,
	wli@holomorphy.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emvkh-0001xJ-UD
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 08:14:43 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emvkg-0002VQ-78
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 08:14:43 -0800
To: Iozone <capps@iozone.org>
In-Reply-To: <02f001c6018d$56b31030$1500000a@americas.hpqcorp.net>
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

On Thu, Dec 15, 2005 at 09:36:37AM -0600, Iozone wrote:
>        With IP_HASHBITS = 8, there were 256 queues,
>    but only one was active. If the hash distribution were
>    uniform, then the queue depth could have been 1 (one)
>    but instead is a linear search of a relatively large number
>    of items.
> 
>    Does that help ?

I'm mainly curious how much effort it's worth expending on optimizing
that hash.  If it turns out that even the current linear search isn't
that expensive, then that's an argument against doing any more
optimizing (beyond just fixing the current obvious problem).

So maybe playing with oprofile or something would help answer my
question.

--b.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
