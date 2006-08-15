From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/22] lockd: make NLM_HOST_MAX tunable
Date: Tue, 15 Aug 2006 16:37:11 +1000
Message-ID: <17633.27543.544197.995369@cse.unsw.edu.au>
References: <20060805130647.GA8016@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCsYF-00049l-Cp
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 23:37:23 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCsYE-0002aa-Lo
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 23:37:24 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 8342D1FC7C
	for <nfs@lists.sourceforge.net>; Tue, 15 Aug 2006 08:37:18 +0200 (CEST)
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Saturday August 5
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Saturday August 5, okir@suse.de wrote:
> From: Olaf Kirch <okir@suse.de>
> Subject: lockd: make NLM_HOST_MAX tunable
> Patch-mainline: not-yet
> 
>   This patch makes NLM_HOST_MAX tunable, and exports the
>   new variable as a sysctl.
>   The old value (64 clients) just wasn't adequate anymore.

Why do we need NLM_HOST_MAX at all?  And if we do, we need
a better name, because it isn't really a maximum.

It is more of a threshold.
While there are fewer than this mean, we garbage collect every 2
minutes discarding hosts more than 5 minutes old.
When we exceed this threshold, we garbage collect every minutes (or
every time a new host is allocated). and discard hosts older than
2 minutes.

It seems like we are picking an arbitrary point at which to switch
from one arbitrary algorithm to another.  Do we really want to do
this?

I cannot see any good reason not to just pick one arbitrary algorithm
and stick with that the whole time.
The only tunable might make sense is the max age before garbage
collection removes hosts.

Am I missing something important?

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
