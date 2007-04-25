From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect
	sub-second	timestamps on etab
Date: Wed, 25 Apr 2007 16:13:54 -0400
Message-ID: <20070425201354.GD6696@salusa.poochiereds.net>
References: <20070425173918.GB6696@salusa.poochiereds.net>
	<20070425180932.GC6696@salusa.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgnsA-00021d-RI
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 13:13:55 -0700
Received: from ms-smtp-02.southeast.rr.com ([24.25.9.101])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgnsD-00063W-2u
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 13:13:57 -0700
Received: from mail.poochiereds.net (cpe-071-070-159-068.nc.res.rr.com
	[71.70.159.68])
	by ms-smtp-02.southeast.rr.com (8.13.6/8.13.6) with ESMTP id
	l3PKDt5V029339
	for <nfs@lists.sourceforge.net>; Wed, 25 Apr 2007 16:13:55 -0400 (EDT)
In-Reply-To: <20070425180932.GC6696@salusa.poochiereds.net>
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

On Wed, Apr 25, 2007 at 02:09:34PM -0400, Jeff Layton wrote:
> On Wed, Apr 25, 2007 at 01:39:20PM -0400, Jeff Layton wrote:
> > Currently, when auth_reload is called, it only looks at the tv_sec field
> > of the mtime when deciding whether to invalidate the exports cache. It's
> > fairly simple to fool this by doing something like:
> > 
> > # exportfs -rv && rpc.mountd && exportfs -uva && exportfs -iv -o no_root_squash,rw 127.0.0.1:/foo
> > 
> > With this, exportfs will show the export for /foo, but mountd will still have
> > whatever contents were in /etc/exports. The issue is that the etab is being
> > updated twice during the same second, and mountd is reading in the file in
> > between updates. When it goes to look at the file again, its timestamp matches
> > the timestamp of the cache, and it ends up keeping the cached contents even
> > though the file has changed.
> > 
> > While not all local filesystems provide sub-second timestamps, we might as
> > well fix this problem on those that do. The following patch changes
> > auth_reload to consider the tv_nsec field of the mtime when deciding whether
> > to invalidate the export cache. It also fixes up the callers to pass it a
> > pointer to a struct timespec for it to fill out.
> > 
> > I've not yet tested this on a filesystem that provides sub-second timestamps,
> > so I'm not clear on how well this works yet, but it seems to not break
> > anything on ext3 in some cursory testing.
> > 
> 
> No sooner than I post than I see a (minor) problem. The check for a NULL
> pointer in auth_reload should be (ts != NULL) instead of (ts). Respun patch
> follows:
> 

I tested this on a filesystem that does nanosecond timestamps (xfs), and it
seems to correct the original problem.
-- Jeff


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
