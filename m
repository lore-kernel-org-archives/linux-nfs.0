From: Kedar Sovani <kedars@hotpop.com>
Subject: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: 06 Sep 2004 18:17:01 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094474821.2284.24.camel@localhost.localdomain>
References: <4124DB86.9060505@steeleye.com>
	 <16677.22269.988036.787320@cse.unsw.edu.au> <412E1C10.5020703@steeleye.com>
	 <20040827073049.GA23324@suse.de> <412F3362.5040707@steeleye.com>
	 <20040830082510.GD28454@suse.de>
	 <1094196525.2283.3.camel@localhost.localdomain>
	 <16699.49563.188086.126554@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olaf Kirch <okir@suse.de>,
	Paul Clements <paul.clements@steeleye.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4IiA-0002HY-3Y
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 05:35:06 -0700
Received: from smtp-out.hotpop.com ([38.113.3.61])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4Ii6-0003NM-DY
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 05:35:06 -0700
Received: from hotpop.com (kubrick.hotpop.com [38.113.3.103])
	by smtp-out.hotpop.com (Postfix) with SMTP id 09429805179
	for <nfs@lists.sourceforge.net>; Mon,  6 Sep 2004 12:34:56 +0000 (UTC)
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16699.49563.188086.126554@cse.unsw.edu.au>
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

On Mon, 2004-09-06 at 07:17, Neil Brown wrote:
> On  September 3, kedars@hotpop.com wrote:
> > NFS Server keeps state about the recent responses given to the clients,
> > in a reply cache.
> > 
> > Shouldn't that state be replicated to the failed-over NFS server as well
> > ?
> 
> The reply cache is an optimisation and cannot be relied upon.  Coping
> it across in a fail-over would be both very expensive (it is highly
> volatile) and of little benefit.
> 
> NeilBrown

Yes, migrating it across server would be very expensive.

But isn't reply cache for correctness (idempotency) as against
optimisation ? 
E.g. 
1. NFS Client sends "create" (file) to the server.
2. Server creates the file and sends a "success" response.
3. The response is lost.
4. The Client retries the "create" 
5. and the NFS Server responds from the _reply cache_ stating that the
result is true. (as the reply was cached in step 2)

Now if the Server crashes after the 3rd step, and the failed over server
starts processing requests, it will respond to the step 4 above with a
FILE EXISTS instead of success, which I think, is incorrect.

Am I missing something ? 
Or probably such scenarios are rare to occur and if they do, are not
much significant, I suppose.

I guess this is what you meant by "of little benefit" above.

thanks,
Kedar.




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
