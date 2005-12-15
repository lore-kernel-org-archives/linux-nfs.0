From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: An interesting performance thing ?
Date: Thu, 15 Dec 2005 12:07:55 -0500
Message-ID: <20051215170755.GD21043@fieldses.org>
References: <17312.39940.985507.704832@cse.unsw.edu.au> <43A0A0D5.4040804@citi.umich.edu> <018401c60108$c9477f30$1500000a@americas.hpqcorp.net> <17312.45710.867019.969182@cse.unsw.edu.au> <20051215023256.GA22951@fieldses.org> <020a01c60133$3d8fc530$1500000a@americas.hpqcorp.net> <20051215144901.GD14973@fieldses.org> <02f001c6018d$56b31030$1500000a@americas.hpqcorp.net> <20051215161431.GA21043@fieldses.org> <031801c60196$60a70ac0$1500000a@americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, cel@citi.umich.edu,
	wli@holomorphy.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmwaJ-00062W-T0
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 09:08:03 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmwaI-0000sz-7N
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 09:08:03 -0800
To: Iozone <capps@iozone.org>
In-Reply-To: <031801c60196$60a70ac0$1500000a@americas.hpqcorp.net>
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

On Thu, Dec 15, 2005 at 10:41:19AM -0600, Iozone wrote:
>        I'm still working on trying to track down the patch to
>    fix RedHat EL 4  (2.6.9-11) so that it will not panic.
>    Until I get that patch located and installed, the profiling
>    may not be very successful :-(

OK!

I think I'd start by looking through patches that touched
include/linux/sunrpc/cache.h:

http://kernel.org/git/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=history;h=9839690102056c6515cff426221522b73eb1a94d;f=include/linux/sunrpc/cache.h

or net/sunrpc/cache.c:

http://kernel.org/git/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=history;h=9839690102056c6515cff426221522b73eb1a94d;f=net/sunrpc/cache.c

The topmost commit there looks like a likely candidate.

--b.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
