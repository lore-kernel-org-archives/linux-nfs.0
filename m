From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Wed, 14 Jul 2004 19:20:42 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040714232042.GA12551@fieldses.org>
References: <40F3D483.8020507@RedHat.com> <20040713143044.GA3023@fieldses.org> <40F3FAD8.7090707@RedHat.com> <20040713151759.GC3023@fieldses.org> <20040713180108.GF3023@fieldses.org> <40F4433A.5090708@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bkt3Q-0000v5-3k
	for nfs@lists.sourceforge.net; Wed, 14 Jul 2004 16:20:48 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bkt3O-0001Sq-5n
	for nfs@lists.sourceforge.net; Wed, 14 Jul 2004 16:20:46 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40F4433A.5090708@RedHat.com>
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

On Tue, Jul 13, 2004 at 04:16:58PM -0400, Steve Dickson wrote:
> IMHO,  its much simpler, easier and less error prone to zero them out 
> than to make nfsstat
> take samples then calculate the differences...


Example 1:
	nfsstat -z
	nfsstat
Example 2:
	nfsstat --checkpoint foo
	nfsstat --since foo

Example 1 is indeed a little simpler to use, but not much.

If you really wanted an interface like that in case 1, you could do that
by storing the checkpointed stats in some default location.

If the typical use is just logging in and collecting a few seconds of
statistics then the easiest thing might be something like

	nfsstat -z
		Collecting statistics.... Hit ^C for results
	^C
	Server rpc stats:
	...etc.

> I just think that a bit over nfsstat's head...

I'm not sure what you mean.  It certainly shouldn't be hard to
implement.

> but I contend that the current nfsd/rpc stats simply aren't these type
> of stats... these are simple activity counters that let you know what
> (if anything) is happening... I think it would be a very difficult
> task to try to used these counts in any long term analysis... I just
> don't think they recored the right type of information for that....

It's not obvious to me why they couldn't be used over long periods.  But
even if the statistics-gathering daemon isn't a good example, I don't
see why there couldn't be other cases where more than one process might
happen to be trying to collect statistics at the same time.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
