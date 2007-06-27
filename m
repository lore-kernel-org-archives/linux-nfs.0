From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Exporting Nested Directories
Date: Wed, 27 Jun 2007 14:57:23 -0400
Message-ID: <20070627145723.9f739db9.jlayton@redhat.com>
References: <19d180740706271141i7592b8bcu9b0c646ab62f550f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3chj-0006RN-O4
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 11:57:54 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3chm-0008VO-V8
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 11:57:31 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l5RIvO7i009184
	for <nfs@lists.sourceforge.net>; Wed, 27 Jun 2007 14:57:24 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l5RIvOnG018117
	for <nfs@lists.sourceforge.net>; Wed, 27 Jun 2007 14:57:24 -0400
Received: from tleilax.poochiereds.net (vpn-14-151.rdu.redhat.com
	[10.11.14.151])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l5RIvNGv002187
	for <nfs@lists.sourceforge.net>; Wed, 27 Jun 2007 14:57:23 -0400
In-Reply-To: <19d180740706271141i7592b8bcu9b0c646ab62f550f@mail.gmail.com>
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

On Wed, 27 Jun 2007 14:41:49 -0400
"Adam Thomas" <nfs@adamthomas.us> wrote:

> I'm trying to export two directories on the same filesystem. The exports
> file looks something like this:
> 
> /raid 192.168.1.0/23(rw,sync)
> /raid/userdir 192.168.1.0/23(rw,sync)
> 

That seems erm...a bit strange.

Any host that has access to /raid will have access to /raid/userdir
automatically. Why not just remove the second export here if they're
truly on the same filesystem? The options are exactly the same.

> When I try to do this I get a lot of unusual behavior (some clients will
> mount, but others won't even though they are within the same IP range).
> 

My first thought is that you may be running into some weirdness with
subtree checking here, though I'll confess that I've not looked closely
at that code in a long time.

> Are there any restriction with exporting a nested directory like this?
> 

There are some. Check out the subtree_check option in the exports
manpage, though for RHEL3 that should already be the default.

> The host is running RHELv3, kernel 2.4.21 with the stock nfs package. The
> clients are all recent version of CentOS or Redhat Linux with the most
> recent nfs-utils packages.
> 
> Thanks,
> -Adam
> 

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
