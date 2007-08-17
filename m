From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] 64 bit ino support for NFS server
Date: Fri, 17 Aug 2007 14:30:31 -0400
Message-ID: <46C5E947.4090903@redhat.com>
References: <46B37DE6.80706@redhat.com> <46B38206.6050504@redhat.com>
	<20070804223256.GA1155@fieldses.org> <46C476DF.3070607@redhat.com>
	<20070817165122.GC28529@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IM6hi-0000ms-FX
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 11:37:52 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IM6bX-0000s3-6d
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 11:31:27 -0700
In-Reply-To: <20070817165122.GC28529@fieldses.org>
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

J. Bruce Fields wrote:
> On Thu, Aug 16, 2007 at 12:10:07PM -0400, Peter Staubach wrote:
>   
>> Attached is a new patch which should address the issues raised
>> by Bruce.
>>     
>
> Thanks!
>
>   
>> I also haven't come to any conclusions regarding the value of
>> lease_get_mtime() and whether it should or should not be invoked
>> by fill_post_wcc() too.  I chose not to change this because I
>> thought that it was safer to leave well enough alone.  If we
>> decide to make a change, it can be done separately.
>>     
>
> OK.
>
> Only superficial complaints:
> 	- There were some minor whitespace oddities; running the patch
> 	  through scripts/checkpatch.pl may be the quickest way to catch
> 	  those.
>   

Ugg.  How did those get in there?  :-)

Thanx for pointing this out.  I will ensure that I run checkpatch
before submitting future patches.

> 	- This would be better as two, maybe three separate patches;
> 	  e.g.  moving the lease_get_mtime out of encode_fattr3 could be
> 	  done separately first.  Ideally we'd do some trivial
> 	  transformations like that, followed by one change that
> 	  actually changes the inode behavior.  That makes the whole
> 	  thing trival to review.
>
>   

My test system isn't at a place where I could factor the patch and
do testing.  For the time being, I'd prefer to stick with the single
patch, since it is tested.
> I fixed up the first and added the result to
>
> 	git://linux-nfs.org/~bfields/linux.git for-mm
>
> so it should show up in the next -mm.  I'd happily replace it by a more
> finely split up version if that was something you could whip up in a few
> minutes.

Thanx, Bruce!

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
