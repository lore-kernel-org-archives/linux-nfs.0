From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 14:57:14 -0400
Message-ID: <20070801185714.GH13441@fieldses.org>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
	<46B0C92C.3020807@redhat.com>
	<Pine.BSO.4.64.0708011413000.25204@citi.umich.edu>
	<46B0CF5B.1000609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	Alex Soule <soule@umich.edu>,
	"david m. richter" <richterd@citi.umich.edu>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGJNn-0006bv-OB
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:57:21 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGJNo-0007nN-6x
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:57:21 -0700
In-Reply-To: <46B0CF5B.1000609@redhat.com>
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

On Wed, Aug 01, 2007 at 02:22:19PM -0400, Peter Staubach wrote:
> Sorry, I should have been more explicit.  I have wished for
> something that would behave like "vmstat 5", ie. print nfsstat
> statistics in some sort short hand fashion once every few
> seconds, 5 in this example.
> 
> The problem has always been that there are too many operations
> for summarize them on one line in any sort of interesting way.
> This becomes particularly true for NFSv4 which has its multitude
> of operations...

Yeah, I agree, it'd be great to have somebody look into this.

Also, do we need code (either in nfsstat or elsewhere) to help people
use the new per-mount client statistics?

I'm guessing among Trond and Neil and people at citi there may not be
anyone with the cycles to implement any of that right now, so these are
projects looking for volunteers.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
