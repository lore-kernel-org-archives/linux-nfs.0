From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] 64 bit ino support for NFS server
Date: Fri, 17 Aug 2007 14:36:01 -0400
Message-ID: <20070817183601.GL28529@fieldses.org>
References: <46B37DE6.80706@redhat.com> <46B38206.6050504@redhat.com>
	<20070804223256.GA1155@fieldses.org> <46C476DF.3070607@redhat.com>
	<20070817165122.GC28529@fieldses.org> <46C5E947.4090903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IM6fz-0000cd-KI
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 11:36:03 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IM6g3-0001DP-5k
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 11:36:07 -0700
In-Reply-To: <46C5E947.4090903@redhat.com>
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

On Fri, Aug 17, 2007 at 02:30:31PM -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
>> 	- This would be better as two, maybe three separate patches;
>> 	  e.g.  moving the lease_get_mtime out of encode_fattr3 could be
>> 	  done separately first.  Ideally we'd do some trivial
>> 	  transformations like that, followed by one change that
>> 	  actually changes the inode behavior.  That makes the whole
>> 	  thing trival to review.
>
> My test system isn't at a place where I could factor the patch and
> do testing.  For the time being, I'd prefer to stick with the single
> patch, since it is tested.

It shouldn't be hard to factor the patch into patches which produce the
identical end result, and are individually trivial enough to be unlikely
to break things partway through.

But the current patch isn't large enough that I'd put my foot down at
this point.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
