From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 0/3] svc: gnb review cleanup for transport switch
Date: Fri, 12 Oct 2007 10:17:14 -0500
Message-ID: <1192202234.30080.21.camel@trinity.ogc.int>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
	<20071011203029.GE22823@fieldses.org>
	<1192140282.7491.33.camel@trinity.ogc.int>
	<20071011220820.GF22823@fieldses.org>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgMHW-0000Tm-9m
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 08:18:30 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IgMHb-0005V1-5k
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 08:18:35 -0700
In-Reply-To: <20071011220820.GF22823@fieldses.org>
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

On Thu, 2007-10-11 at 18:08 -0400, J. Bruce Fields wrote:
> On Thu, Oct 11, 2007 at 05:04:42PM -0500, Tom Tucker wrote:
> > I think I found the problem. The patchset is not caching the auth data
> > properly. This causes the server to fail the setting of the client id
> > with a 10018 error.
> > 
> > I'll send a patch off tonight....sorry :-\

A quick update. The problem is not what I thought it was, but I did
discover some interesting things:

- If you wait 60 seconds after the nfs4 mount, everything works fine.
You can run connectathon and the world is happy. Before the 60 seconds
you get the hang. Curiously, there are connection management timers in
the client that have this value.

- It looks like the module load logic that is down in the
crypto_alloc_hash path is not working properly. Maybe the module name
changed or something, or maybe it always worked this way and I'm
confused, but you have to manually load md5 for nfs4 to work

- It looks like the callback path is still broken. It's not the port
number, it's the IP address. Since I moved the IP address, it's likely
that I'm the culprit. 

I'll keep you updated,
Tom

> 
> OK, thanks!
> 
> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
