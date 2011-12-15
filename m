Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651Ab1LOPC5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 10:02:57 -0500
Date: Thu, 15 Dec 2011 10:04:30 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] clstated: add routines for a sqlite backend
 database
Message-ID: <20111215100430.6ba21ca4@barsoom.rdu.redhat.com>
In-Reply-To: <52E5C825-1796-4307-9B0D-BB7151A614B9@oracle.com>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
	<1323871032-3191-5-git-send-email-jlayton@redhat.com>
	<648A4373-871E-4C1C-A920-F55E5D9D390E@oracle.com>
	<20111214101417.4bf4dffd@tlielax.poochiereds.net>
	<E69EC34A-36AE-4B85-B991-029EA9A7B750@oracle.com>
	<20111214111545.43a78e1f@tlielax.poochiereds.net>
	<52E5C825-1796-4307-9B0D-BB7151A614B9@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 15 Dec 2011 09:55:59 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Dec 14, 2011, at 11:15 AM, Jeff Layton wrote:
> 
> > On Wed, 14 Dec 2011 10:47:56 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> 
> >> On Dec 14, 2011, at 10:14 AM, Jeff Layton wrote:
> >> 
> >>> On Wed, 14 Dec 2011 09:56:32 -0500
> >>> Chuck Lever <chuck.lever@oracle.com> wrote:
> >>> 
> >>>> 
> >>>> On Dec 14, 2011, at 8:57 AM, Jeff Layton wrote:
> >>>> 
> >>>>> Rather than roll our own "storage engine", use sqlite instead. It fits
> >>>>> the bill nicely as it does:
> >>>>> 
> >>>>> - durable on-disk storage
> >>>>> - the ability to constrain record uniqueness
> >>>>> - a facility for collating and searching the host records
> >>>> 
> >>>> It should also allow multiple processes (possibly on multiple cluster nodes) to access the on-disk data safely and atomically.  No need to invent a file locking scheme from scratch.
> >>>> 
> >>> 
> >>> Indeed. That's one of the main reasons I chose sqlite here.
> >>> 
> >>>>> ...it does add a build dependency to nfs-utils, but almost all modern
> >>>>> distros provide those packages.
> >>>>> 
> >>>>> The current incarnation of this code dynamically links against a
> >>>>> provided sqlite library, but we could also consider including their
> >>>>> single-file "amalgamation" to reduce dependencies (though with all
> >>>>> the caveats that that entails).
> >>>>> 
> >>>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> >>>>> ---
> >>>>> utils/clstated/Makefile.am |    4 +-
> >>>>> utils/clstated/clstated.c  |   16 ++-
> >>>>> utils/clstated/sqlite.c    |  351 ++++++++++++++++++++++++++++++++++++++++++++
> >>>>> utils/clstated/sqlite.h    |   27 ++++
> >>>>> 4 files changed, 393 insertions(+), 5 deletions(-)
> >>>>> create mode 100644 utils/clstated/sqlite.c
> >>>>> create mode 100644 utils/clstated/sqlite.h
> >>>>> 
> >>>>> diff --git a/utils/clstated/Makefile.am b/utils/clstated/Makefile.am
> >>>>> index 9937353..d1cef3c 100644
> >>>>> --- a/utils/clstated/Makefile.am
> >>>>> +++ b/utils/clstated/Makefile.am
> >>>>> @@ -6,9 +6,9 @@
> >>>>> AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
> >>>>> sbin_PROGRAMS	= clstated
> >>>>> 
> >>>>> -clstated_SOURCES = clstated.c
> >>>>> +clstated_SOURCES = clstated.c sqlite.c
> >>>>> 
> >>>>> -clstated_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT)
> >>>>> +clstated_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT) $(LIBSQLITE)
> >>>>> 
> >>>>> MAINTAINERCLEANFILES = Makefile.in
> >>>>> 
> >>>>> diff --git a/utils/clstated/clstated.c b/utils/clstated/clstated.c
> >>>>> index aab09a7..95ac696 100644
> >>>>> --- a/utils/clstated/clstated.c
> >>>>> +++ b/utils/clstated/clstated.c
> >>>>> @@ -36,6 +36,7 @@
> >>>>> 
> >>>>> #include "xlog.h"
> >>>>> #include "nfslib.h"
> >>>>> +#include "sqlite.h"
> >>>>> 
> >>>>> #ifndef PIPEFS_DIR
> >>>>> #define PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
> >>>>> @@ -118,21 +119,25 @@ clstate_pipe_reopen(struct clstate_client *clnt)
> >>>>> static void
> >>>>> clstate_create(struct clstate_client *clnt)
> >>>>> {
> >>>>> +	int ret;
> >>>>> 	ssize_t bsize, wsize;
> >>>>> 	struct clstate_msg *cmsg = &clnt->cl_msg;
> >>>>> 
> >>>>> -	xlog(D_GENERAL, "%s: create client record", __func__);
> >>>>> +	xlog(D_GENERAL, "%s: create client record. cm_addr=%s", __func__,
> >>>>> +			cmsg->cm_addr);
> >>>>> 
> >>>>> -	/* FIXME: create client record on storage here */
> >>>>> +	ret = clstate_insert_client(cmsg->cm_addr, cmsg->cm_u.cm_id,
> >>>>> +					cmsg->cm_len);
> >>>>> 
> >>>>> 	/* set up reply */
> >>>>> -	cmsg->cm_status = 0;
> >>>>> +	cmsg->cm_status = ret ? -EREMOTEIO : ret;
> >>>>> 	cmsg->cm_len = 0;
> >>>>> 	memset(cmsg->cm_addr, 0, sizeof(cmsg->cm_addr) +
> >>>>> 		sizeof(cmsg->cm_u.cm_id));
> >>>>> 
> >>>>> 	bsize = sizeof(*cmsg);
> >>>>> 
> >>>>> +	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
> >>>>> 	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
> >>>>> 	if (wsize != bsize) {
> >>>>> 		xlog(L_ERROR, "%s: problem writing to clstate pipe (%ld): %m",
> >>>>> @@ -231,6 +236,11 @@ main(int argc, char **argv)
> >>>>> 	}
> >>>>> 
> >>>>> 	/* set up storage db */
> >>>>> +	rc = clstate_maindb_init();
> >>>>> +	if (rc) {
> >>>>> +		xlog(L_ERROR, "Failed to open main database: %d", rc);
> >>>>> +		goto out;
> >>>>> +	}
> >>>>> 
> >>>>> 	/* set up event handler */
> >>>>> 	fd = clstate_pipe_open(&clnt);
> >>>>> diff --git a/utils/clstated/sqlite.c b/utils/clstated/sqlite.c
> >>>>> new file mode 100644
> >>>>> index 0000000..ae83634
> >>>>> --- /dev/null
> >>>>> +++ b/utils/clstated/sqlite.c
> >>>>> @@ -0,0 +1,351 @@
> >>>>> +/*
> >>>>> + * Copyright (C) 2011  Red Hat, Jeff Layton <jlayton@redhat.com>
> >>>>> + *
> >>>>> + * This program is free software; you can redistribute it and/or
> >>>>> + * modify it under the terms of the GNU General Public License
> >>>>> + * as published by the Free Software Foundation; either version 2
> >>>>> + * of the License, or (at your option) any later version.
> >>>>> + *
> >>>>> + * This program is distributed in the hope that it will be useful,
> >>>>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> >>>>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> >>>>> + * GNU General Public License for more details.
> >>>>> + *
> >>>>> + * You should have received a copy of the GNU General Public License
> >>>>> + * along with this program; if not, write to the Free Software
> >>>>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor,
> >>>>> + * Boston, MA 02110-1301, USA.
> >>>>> + */
> >>>>> +
> >>>>> +/*
> >>>>> + * Explanation:
> >>>>> + *
> >>>>> + * This file contains the code to manage the sqlite backend database for the
> >>>>> + * clstated upcall daemon.
> >>>>> + *
> >>>>> + * The main database is called main.sqlite and contains the following tables:
> >>>>> + *
> >>>>> + * parameters: simple key/value pairs for storing database info
> >>>>> + *
> >>>>> + * addresses: list of server-side addresses recorded in the db, along with
> >>>>> + * 	      the filenames of their respective db files.
> >>>>> + *
> >>>>> + * The daemon attaches to each server-address database as needed. Each
> >>>>> + * server-address database has the following tables:
> >>>> 
> >>>> Why do you keep separate database files?  There are ways to store all of this data in a single database using multiple tables.  I'm happy to help you with table design if you like.
> >>>> 
> >>> 
> >>> As you pointed out above, sqlite allows us to share the db directory
> >>> across a cluster of nodes. Using different files here will allow us to
> >>> reduce lock contention in the cluster. If we put each server address DB
> >>> in a separate file, then only the node that currently owns that address
> >>> should need to touch it under normal circumstances.
> >> 
> >> This seems like premature optimization.  A single file is much simpler and I'm guessing would be a more standard arrangement of tables.  If cluster contention avoidance is a key design point, it's worth calling out in the documenting comment, because this multi-file arrangement is not a typical use of sqlite3.
> >> 
> >> Why do you predict that the database will be under contention?  Isn't it the case that sqlite3 can allow multiple accessors to a single database file?
> >> 
> > 
> > Since the grace periods will need to be coordinated, then it's likely
> > on a server reboot that clients will be reestablishing state with
> > multiple nodes in the cluster at a time. That means at least some
> > contention for the DB. Whether it's problematic or not is an open
> > question at this point, but why not avoid that if we can?
> 
> Yes, there may be contention during reclaim.  However, I submit that we don't understand the details of that well enough to solidify a design for handling that workload scalably at this point.  I recommend some simple prototyping and careful modeling to understand exactly what's going to happen in such a scenario.  Then we can approach a client ID database design with good information about what needs to scale and what can be designed for convenience.  :-)
> 
> Just a thought.
> 

Fair enough. That's probably reasonable and not using separate DB's
simplifies the code considerably. You also mentioned on IRC yesterday,
that segregating the records by server address would break the UCS
migration model, so I'm planning to abandon that model anyway.

I have a revised set of patches that I'm testing now that should
address these concerns. It also renames the daemon and kernel
structures to adhere more closely to what Steve would prefer. In the
absence of a NAK for solid technical reasons, I'm sticking with sqlite
for now.

-- 
Jeff Layton <jlayton@redhat.com>
