From: "Roger Willcocks" <roger-nMHR1cC4sak0YOejwGmHqw@public.gmane.org>
Subject: Re: [NFS] nfsd bug: create file with specific uid/gid
Date: Sat, 1 Dec 2007 11:36:18 -0000
Message-ID: <01bf01c8340e$63e90060$6501a8c0__35787.0381245904$1196509079$gmane$org@BODDINGTON>
References: <475042FB.8020106@filmlight.ltd.uk>
	<20071130220127.GJ24887@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:40807 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbXLALhF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 1 Dec 2007 06:37:05 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1IyQeY-0007p2-GH
	for linux-nfs@vger.kernel.org; Sat, 01 Dec 2007 22:36:58 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

> On Fri, Nov 30, 2007 at 05:06:03PM +0000, Roger Willcocks wrote:
>> nfsd/vfs.c:nfsd_create (the v2 version of create) says:
>>
>> "Set file attributes. Mode has already been set and
>> setting uid/gid works only for root"
>>
>> but it doesn't actually test for root-ness
...
> Assignments (especially with things like &=) inside of conditionals
> always make my head hurt for some reason.  So maybe something like the
> below?

The patch looks fine to me, note that nfsd_create_v3 needs fixing too.

>
> Thanks for the bug report!  (And, by the way, how did you run across
> this?)
>

I'm working on an NFSp-like server for our clustered file system and my data 
file creates were not working as expected.

--
Roger


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

