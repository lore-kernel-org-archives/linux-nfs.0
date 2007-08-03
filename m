From: Neil Brown <neilb@suse.de>
Subject: Re: NFS Caching / Locking
Date: Fri, 3 Aug 2007 17:13:02 +1000
Message-ID: <18098.54654.108131.864508@notabene.brown>
References: <F31FEAB987B7C2469181758C14265CFA040BBABB@gvlexch03.is.l-3com.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Mock, JV Jason @ IS" <Jason.V.Mock@L-3Com.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGrLb-0007fP-Kv
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 00:13:19 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGrLf-0001Rx-4A
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 00:13:23 -0700
In-Reply-To: message from Mock, JV Jason @ IS on Thursday August 2
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday August 2, Jason.V.Mock@L-3Com.com wrote:
> We've got a few problems, which I'd like to explain, that we need some
> suggestions on methods of correction.  The first being caching where
> client machines would see changes to a written file anywhere from 5 to
> 60 seconds later.  The clients are running RHEL4 (2.6.9-32 with
> nfs-utils 1.0.6 - yea yea... I know... ancient...).  I know that
> O_DIRECT can help override the caching, however some of the worst
> effects appear to be with command line calls where we don't have the
> ability/time to modify how they open files.  Just to try to get another
> point of data to work with, we've loaded up 2.6.22.1 with nfs-utils
> 1.0.8 (and additionally tried 1.1.0), and we appear to be having less
> problems except for a few occasional delays with executed commands and
> are not able to view locks on all machines (locks are only visible on
> the system that locked the file).  We have no problem using either
> kernel, but we'd love to try to figure out each of these problems.  I
> read through the NFS.sourceforge.net page the comment that "attribute
> caching" and "data caching" are two seperate things.  In that context
> they recommended O_DIRECT to resolve data caching, however is there any
> kind of flag that we can flip to say do not cache data?  At least
> 2.6.22.1 is some what of an improvement on the caching...  if we could
> just resolve the locking issues... would anyone have suggestions on
> where to look to correct that?  I don't mind getting the NFS calls
> themselves and the code if need be...

Could you please give more details on the perceived "locking problem"?

All you say is :
> are not able to view locks on all machines (locks are only visible on
> the system that locked the file).

What do you mean by "view lock"??  Do you mean look in /proc/locks?
Certainly only the client and the server would be able to see any
locks in /proc/locks.  All other clients wouldn't be able to detect
the lock until they try to claim it.

NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
