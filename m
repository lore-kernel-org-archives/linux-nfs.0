Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46264 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754898AbZLBAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Dec 2009 19:38:42 -0500
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Cc: Steve Dickson <steved@redhat.com>
Subject: pseudoroot kernel patches
Date: Tue,  1 Dec 2009 19:39:36 -0500
Message-Id: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is my revision of Steve Dickson's series of patches that allow
automatically constructing the NFSv4 psuedoroot.  I think it's close to
a final version.

The basic idea is for mountd to automatically export all of the
filesystems which must be traversed to reach any exported filesystem.
This raises obvious security concerns.  Steved's solution is to greatly
restrict access to those exports, by adding a new export flag
(NFSEXP_V4ROOT), which tells the kernel that *only* the single object at
the given path is meant to be exported, *not* the rest of the filesystem
underneath it.  Thus mountd actually generates a separate export for
every directory along the path to a real export.

Changes since the last version steved posted:
	- fix nfsd_verify to prevent filehandle-guessing attacks from
	  allowing access to unexported objects on V4ROOT filesystems.
	- fix a bug which could cause NFSv4's readdir to return bad
	  filehandles for directory entries.
	- Allow V4ROOT exports of symlink objects (to allow the path
	  listed in /etc/exports to be a symlink, as has traditionally
	  been permitted with v2/v3).  The mountd side of this is not
	  yet written.
	- Simplify the code somewhat by moving most of the readdir and
	  lookup checks into nfsd_crossmnt.

Some problems will remain:

The exported v4 namespace will still not be entirely identical with the
v2/v3 namespace; to some degree this is inevitable:

	- If /export and /export/foo are two different filesystems, both
	  exported, then a v2/v3 client that mounts /export will not see
	  the filesystem /foo.

	  This is an inherent limitation of the v2/v3 protocols, which
	  don't require clients to know how to traverse mountpoints.
	  
	  The server's current behavior in this case is simply to show
	  the contents of the directory named "foo" on the filesystem
	  /export.   This may allow the client to see (even create)
	  directory objects on /export which are invisible to users on
	  the server, because the filesystem mounted on top of
	  /export/foo hides them.

	  We could instead modify the server to hide the contents of
	  foo/ from the client somehow.  This must be done carefully:
	  the directory "foo" itself must still be present in case the
	  client wants to mount something there itself.

	- Nested exports on the same filesystem also pose a problem;
	  given:
		/export		*(rw)
		/export/foo	*(ro)
	  with foo on the same filesystem as /export,
	  	mount -tnfs server:/export/foo /mnt
	  will give a read-only filesystem,
		mount -nfs4 server:/export/foo /mnt
	  will give a read-write filesystem.  A v4 client won't see
	  any change in export options as it traverses into foo.

There are also some potential drawbacks to this approach, which we can
probably live with:

	- It requires creating an entry in the export cache for any
	  directory that is an ancestor of a directory, and for every
	  entry of each directory (a negative cache entry in the case of
	  entries that don't lead to exports).  Improvements in the
	  cache management may be sufficient to mitigate problems that
	  show up.
	- Handling filehandle->export mapping will require stat'ing all
	  the parents of exports, as well as exports, possibility
	  exacerbating problems previously raised on this list with
	  spinning up idle disks unnecessarily.
	- It will never work in cases where "/" and other filesystems
	  which must be traversed on the way to an export are not
	  themselves nfs-exportable.  This is probably a rare corner
	  case, but we've seen at least one example of somebody doing
	  embedded work who does this.  We should at least make sure we
	  fail gracefully in this case (e.g. by turning off attempts to
	  build pseudofilesystem).
	- It doesn't provide a simple upgrade path for anyone using the
	  current manual pseudoroot-construction who would also like
	  paths consistent with v2/v3.  That problem is actually very
	  simple to solve in nfs-utils, and I'll post patches for that.
	- The additional automatic exports may raise security risks.  I
	  believe we're now restricting access correctly, but additional
	  eyes here wouldn't hurt.

Before we merge this, I'd also like to look a little more into which
interfaces V4ROOT exports should be visible (versus which they should be
hidden from--as they're not quite "real" exports).  And we have a few
problems on the nfs-utils side which I believe Steve is resolving (if he
hasn't already).

--b.
