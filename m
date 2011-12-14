Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:32882 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756193Ab1LNPsE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2011 10:48:04 -0500
Subject: Re: [PATCH 4/7] clstated: add routines for a sqlite backend database
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111214101417.4bf4dffd@tlielax.poochiereds.net>
Date: Wed, 14 Dec 2011 10:47:56 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <E69EC34A-36AE-4B85-B991-029EA9A7B750@oracle.com>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com> <1323871032-3191-5-git-send-email-jlayton@redhat.com> <648A4373-871E-4C1C-A920-F55E5D9D390E@oracle.com> <20111214101417.4bf4dffd@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 14, 2011, at 10:14 AM, Jeff Layton wrote:

> On Wed, 14 Dec 2011 09:56:32 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Dec 14, 2011, at 8:57 AM, Jeff Layton wrote:
>> 
>>> Rather than roll our own "storage engine", use sqlite instead. It fits
>>> the bill nicely as it does:
>>> 
>>> - durable on-disk storage
>>> - the ability to constrain record uniqueness
>>> - a facility for collating and searching the host records
>> 
>> It should also allow multiple processes (possibly on multiple cluster nodes) to access the on-disk data safely and atomically.  No need to invent a file locking scheme from scratch.
>> 
> 
> Indeed. That's one of the main reasons I chose sqlite here.
> 
>>> ...it does add a build dependency to nfs-utils, but almost all modern
>>> distros provide those packages.
>>> 
>>> The current incarnation of this code dynamically links against a
>>> provided sqlite library, but we could also consider including their
>>> single-file "amalgamation" to reduce dependencies (though with all
>>> the caveats that that entails).
>>> 
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>> ---
>>> utils/clstated/Makefile.am |    4 +-
>>> utils/clstated/clstated.c  |   16 ++-
>>> utils/clstated/sqlite.c    |  351 ++++++++++++++++++++++++++++++++++++++++++++
>>> utils/clstated/sqlite.h    |   27 ++++
>>> 4 files changed, 393 insertions(+), 5 deletions(-)
>>> create mode 100644 utils/clstated/sqlite.c
>>> create mode 100644 utils/clstated/sqlite.h
>>> 
>>> diff --git a/utils/clstated/Makefile.am b/utils/clstated/Makefile.am
>>> index 9937353..d1cef3c 100644
>>> --- a/utils/clstated/Makefile.am
>>> +++ b/utils/clstated/Makefile.am
>>> @@ -6,9 +6,9 @@
>>> AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
>>> sbin_PROGRAMS	= clstated
>>> 
>>> -clstated_SOURCES = clstated.c
>>> +clstated_SOURCES = clstated.c sqlite.c
>>> 
>>> -clstated_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT)
>>> +clstated_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT) $(LIBSQLITE)
>>> 
>>> MAINTAINERCLEANFILES = Makefile.in
>>> 
>>> diff --git a/utils/clstated/clstated.c b/utils/clstated/clstated.c
>>> index aab09a7..95ac696 100644
>>> --- a/utils/clstated/clstated.c
>>> +++ b/utils/clstated/clstated.c
>>> @@ -36,6 +36,7 @@
>>> 
>>> #include "xlog.h"
>>> #include "nfslib.h"
>>> +#include "sqlite.h"
>>> 
>>> #ifndef PIPEFS_DIR
>>> #define PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
>>> @@ -118,21 +119,25 @@ clstate_pipe_reopen(struct clstate_client *clnt)
>>> static void
>>> clstate_create(struct clstate_client *clnt)
>>> {
>>> +	int ret;
>>> 	ssize_t bsize, wsize;
>>> 	struct clstate_msg *cmsg = &clnt->cl_msg;
>>> 
>>> -	xlog(D_GENERAL, "%s: create client record", __func__);
>>> +	xlog(D_GENERAL, "%s: create client record. cm_addr=%s", __func__,
>>> +			cmsg->cm_addr);
>>> 
>>> -	/* FIXME: create client record on storage here */
>>> +	ret = clstate_insert_client(cmsg->cm_addr, cmsg->cm_u.cm_id,
>>> +					cmsg->cm_len);
>>> 
>>> 	/* set up reply */
>>> -	cmsg->cm_status = 0;
>>> +	cmsg->cm_status = ret ? -EREMOTEIO : ret;
>>> 	cmsg->cm_len = 0;
>>> 	memset(cmsg->cm_addr, 0, sizeof(cmsg->cm_addr) +
>>> 		sizeof(cmsg->cm_u.cm_id));
>>> 
>>> 	bsize = sizeof(*cmsg);
>>> 
>>> +	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
>>> 	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
>>> 	if (wsize != bsize) {
>>> 		xlog(L_ERROR, "%s: problem writing to clstate pipe (%ld): %m",
>>> @@ -231,6 +236,11 @@ main(int argc, char **argv)
>>> 	}
>>> 
>>> 	/* set up storage db */
>>> +	rc = clstate_maindb_init();
>>> +	if (rc) {
>>> +		xlog(L_ERROR, "Failed to open main database: %d", rc);
>>> +		goto out;
>>> +	}
>>> 
>>> 	/* set up event handler */
>>> 	fd = clstate_pipe_open(&clnt);
>>> diff --git a/utils/clstated/sqlite.c b/utils/clstated/sqlite.c
>>> new file mode 100644
>>> index 0000000..ae83634
>>> --- /dev/null
>>> +++ b/utils/clstated/sqlite.c
>>> @@ -0,0 +1,351 @@
>>> +/*
>>> + * Copyright (C) 2011  Red Hat, Jeff Layton <jlayton@redhat.com>
>>> + *
>>> + * This program is free software; you can redistribute it and/or
>>> + * modify it under the terms of the GNU General Public License
>>> + * as published by the Free Software Foundation; either version 2
>>> + * of the License, or (at your option) any later version.
>>> + *
>>> + * This program is distributed in the hope that it will be useful,
>>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>>> + * GNU General Public License for more details.
>>> + *
>>> + * You should have received a copy of the GNU General Public License
>>> + * along with this program; if not, write to the Free Software
>>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor,
>>> + * Boston, MA 02110-1301, USA.
>>> + */
>>> +
>>> +/*
>>> + * Explanation:
>>> + *
>>> + * This file contains the code to manage the sqlite backend database for the
>>> + * clstated upcall daemon.
>>> + *
>>> + * The main database is called main.sqlite and contains the following tables:
>>> + *
>>> + * parameters: simple key/value pairs for storing database info
>>> + *
>>> + * addresses: list of server-side addresses recorded in the db, along with
>>> + * 	      the filenames of their respective db files.
>>> + *
>>> + * The daemon attaches to each server-address database as needed. Each
>>> + * server-address database has the following tables:
>> 
>> Why do you keep separate database files?  There are ways to store all of this data in a single database using multiple tables.  I'm happy to help you with table design if you like.
>> 
> 
> As you pointed out above, sqlite allows us to share the db directory
> across a cluster of nodes. Using different files here will allow us to
> reduce lock contention in the cluster. If we put each server address DB
> in a separate file, then only the node that currently owns that address
> should need to touch it under normal circumstances.

This seems like premature optimization.  A single file is much simpler and I'm guessing would be a more standard arrangement of tables.  If cluster contention avoidance is a key design point, it's worth calling out in the documenting comment, because this multi-file arrangement is not a typical use of sqlite3.

Why do you predict that the database will be under contention?  Isn't it the case that sqlite3 can allow multiple accessors to a single database file?

> 
>>> + *
>>> + * clients: one column containing a BLOB with the clstate as sent by the client
>>> + * 	    and a timestamp (in epoch seconds) of when the record was
>>> + * 	    established
>> 
>> I'm not yet clear on what's in cm_addr, but it seems to me that if you store each client's data as structured fields instead of a single BLOB, it will be much easier to use a generic tool like the sqlite3 command to debug the database.  That gives the observability and transparency of using a flat file with all the advantages of a database.
>> 
>> Plus, you get automatic data conversion; a one-to-one mapping between data on-disk and data in any endian-ness or word length.
>> 
> 
> cm_addr is the *server's* address.

What if a server has more than one address?  For example, an IPv4 and an IPv6 address?  Does it get two separate database files?  If so, how do you ensure that a client's nfs_client_id4 is recorded in both places atomically?  I'm not sure tying the server's identity to an IP address is wise.

Even if this is not a complex data item, I think opaque BLOBs should be avoided.  Store the presentation address in a text field.  Data conversion and observability are still strong reasons to do this.

> One key point here is that (at least
> in v4.0), clients do not SETCLIENTID against a server, but rather
> against the server's address. If the client needs to talk to another
> address it must call SETCLIENTID again. So, it's reasonable to track
> the client names on a per-server address basis to reduce DB contention
> in a clustered configuration.
> 
>>> + *
>>> + * FIXME: should we also record the fsid being accessed?
>> 
>> I'm not exactly sure what additional data might be needed to support NFSv4 migration, for example.  However, using a database means it's relatively painless to add new columns in the future without having to provision them now.
>> 
> 
> Right. It's just a matter of adding the correct column and somehow
> populating them for existing entries. Making this extensible is a
> design goal here. It's a complex enough problem, that I'm fairly
> certain I'll get something wrong on the first pass...

You don't necessarily need to populate new columns for existing rows by the way.  Simply add the column to the table.  Existing rows will return a special result meaning "no value."  Your code can choose a default value in that case.

Anyway, that's a detail.

> 
>>> + */
>>> +
>>> +#ifdef HAVE_CONFIG_H
>>> +#include "config.h"
>>> +#endif /* HAVE_CONFIG_H */
>>> +
>>> +#include <errno.h>
>>> +#include <event.h>
>>> +#include <stdbool.h>
>>> +#include <string.h>
>>> +#include <sys/stat.h>
>>> +#include <sys/types.h>
>>> +#include <fcntl.h>
>>> +#include <unistd.h>
>>> +#include <sqlite3.h>
>>> +#include <linux/limits.h>
>>> +#include <linux/nfsd/clstate.h>
>>> +
>>> +#include "xlog.h"
>>> +
>>> +#define CLSTATE_SQLITE_SCHEMA_VERSION 1
>>> +
>>> +#ifndef CLSTATE_DIR
>>> +#define CLSTATE_DIR NFS_STATEDIR "/clstate"
>>> +#endif
>>> +
>>> +/* in milliseconds */
>>> +#define CLSTATE_SQLITE_BUSY_TIMEOUT 10000
>>> +
>>> +/* private data structures */
>>> +
>>> +/* global variables */
>>> +
>>> +/* top level DB directory */
>>> +static char *clstate_topdir = CLSTATE_DIR;
>>> +
>>> +/* reusable pathname and sql command buffer */
>>> +static char buf[PATH_MAX];
>>> +
>>> +/* global database handle */
>>> +static sqlite3 *dbh;
>>> +
>>> +/* forward declarations */
>>> +
>>> +/* '.' is not allowed in dbnames -- convert them to '-' */
>>> +static void
>>> +addr_to_dbname(const char *src, char *dst)
>>> +{
>>> +	while(*src) {
>>> +		if (*src == '.')
>>> +			*dst = '-';
>>> +		else
>>> +			*dst = *src;
>>> +		++src;
>>> +		++dst;
>>> +	}
>>> +	*dst = '\0';
>>> +}
>>> +
>>> +void
>>> +clstate_set_topdir(char *topdir)
>>> +{
>>> +	clstate_topdir = topdir;
>>> +}
>>> +
>>> +/* make a directory, ignoring EEXIST errors unless it's not a directory */
>>> +static int
>>> +mkdir_if_not_exist(char *dirname)
>>> +{
>>> +	int ret;
>>> +	struct stat statbuf;
>>> +
>>> +	ret = mkdir(dirname, S_IRWXU);
>>> +	if (ret && errno != EEXIST)
>>> +		return -errno;
>>> +
>>> +	ret = stat(dirname, &statbuf);
>>> +	if (ret)
>>> +		return -errno;
>>> +
>>> +	if (!S_ISDIR(statbuf.st_mode))
>>> +		ret = -ENOTDIR;
>>> +
>>> +	return ret;
>>> +}
>>> +
>>> +/*
>>> + * Open the "main" database, and attempt to initialize it by creating the
>>> + * parameters table and inserting the schema version into it. Ignore any errors
>>> + * from that, and then attempt to select the version out of it again. If the
>>> + * version appears wrong, then assume that the DB is corrupt or has been
>>> + * upgraded, and return an error.
>>> + */
>>> +int
>>> +clstate_maindb_init(void)
>>> +{
>>> +	int ret;
>>> +	char *err = NULL;
>>> +	sqlite3_stmt *stmt = NULL;
>>> +
>>> +	ret = mkdir_if_not_exist(clstate_topdir);
>>> +	if (ret)
>>> +		return ret;
>>> +
>>> +	ret = snprintf(buf, PATH_MAX - 1, "%s/main.sqlite", clstate_topdir);
>>> +	if (ret < 0)
>>> +		return ret;
>>> +
>>> +	buf[PATH_MAX - 1] = '\0';
>>> +
>>> +	ret = sqlite3_open(buf, &dbh);
>>> +	if (ret != SQLITE_OK) {
>>> +		xlog(D_GENERAL, "Unable to open main database: %d", ret);
>>> +		return ret;
>>> +	}
>>> +
>>> +	ret = sqlite3_busy_timeout(dbh, CLSTATE_SQLITE_BUSY_TIMEOUT);
>>> +	if (ret != SQLITE_OK) {
>>> +		xlog(D_GENERAL, "Unable to set sqlite busy timeout: %d", ret);
>>> +		goto out_err;
>>> +	}
>>> +
>>> +	/* Try to create table */
>>> +	ret = sqlite3_exec(dbh, "CREATE TABLE IF NOT EXISTS parameters "
>>> +				"(key TEXT PRIMARY KEY, value TEXT);",
>>> +				NULL, NULL, &err);
>>> +	if (ret != SQLITE_OK) {
>>> +		xlog(D_GENERAL, "Unable to create parameter table: %d", ret);
>>> +		goto out_err;
>>> +	}
>>> +
>>> +	/* insert version into table -- ignore error if it fails */
>>> +	ret = snprintf(buf, sizeof(buf),
>>> +		       "INSERT OR IGNORE INTO parameters values (\"version\", "
>>> +		       "\"%d\");", CLSTATE_SQLITE_SCHEMA_VERSION);
>>> +	if (ret < 0) {
>>> +		goto out_err;
>>> +	} else if ((size_t)ret >= sizeof(buf)) {
>>> +		ret = -EINVAL;
>>> +		goto out_err;
>>> +	}
>>> +
>>> +	ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
>>> +	if (ret != SQLITE_OK) {
>>> +		xlog(D_GENERAL, "Unable to insert into parameter table: %d",
>>> +				ret);
>>> +		goto out_err;
>>> +	}
>>> +
>>> +	ret = sqlite3_prepare_v2(dbh,
>>> +		"SELECT value FROM parameters WHERE key == \"version\";",
>>> +		 -1, &stmt, NULL);
>>> +	if (ret != SQLITE_OK) {
>>> +		xlog(D_GENERAL, "Unable to prepare select statement: %d", ret);
>>> +		goto out_err;
>>> +	}
>>> +
>>> +	/* check schema version */
>>> +	ret = sqlite3_step(stmt);
>>> +	if (ret != SQLITE_ROW) {
>>> +		xlog(D_GENERAL, "Select statement execution failed: %s",
>>> +				sqlite3_errmsg(dbh));
>>> +		goto out_err;
>>> +	}
>>> +
>>> +	/* process SELECT result */
>>> +	ret = sqlite3_column_int(stmt, 0);
>>> +	if (ret != CLSTATE_SQLITE_SCHEMA_VERSION) {
>>> +		xlog(L_ERROR, "Unsupported database schema version! "
>>> +			"Expected %d, got %d.",
>>> +			CLSTATE_SQLITE_SCHEMA_VERSION, ret);
>>> +		ret = -EINVAL;
>>> +		goto out_err;
>>> +	}
>>> +
>>> +	sqlite3_free(err);
>>> +	sqlite3_finalize(stmt);
>>> +	return 0;
>>> +
>>> +out_err:
>>> +	if (err) {
>>> +		xlog(L_ERROR, "sqlite error: %s", err);
>>> +		sqlite3_free(err);
>>> +	}
>>> +	sqlite3_finalize(stmt);
>>> +	sqlite3_close(dbh);
>>> +	return ret;
>>> +}
>>> +
>>> +static int
>>> +clstate_db_attach(char *dbname)
>>> +{
>>> +	int ret;
>>> +	char *err;
>>> +
>>> +	/* convert address string into valid filename */
>>> +	ret = snprintf(buf, sizeof(buf),
>>> +			"ATTACH DATABASE \"%s/%s.sqlite\" as \"%s\";",
>>> +			clstate_topdir, dbname, dbname);
>>> +	if (ret < 0) {
>>> +		return ret;
>>> +	} else if ((size_t)ret >= sizeof(buf)) {
>>> +		ret = -EINVAL;
>>> +		return ret;
>>> +	}
>>> +
>>> +	/* attach to new DB in filename */
>>> +	ret = sqlite3_exec(dbh, buf, NULL, NULL, &err);
>>> +	if (ret != SQLITE_OK)
>>> +		xlog(L_ERROR, "Unable to attach database %s: %s", dbname, err);
>>> +
>>> +	xlog(D_GENERAL, "Attached database %s", dbname);
>>> +	return ret;
>>> +}
>>> +
>>> +static int
>>> +clstate_db_detach(char *dbname)
>>> +{
>>> +	int ret;
>>> +	char *err;
>>> +
>>> +	/* convert address string into valid filename */
>>> +	ret = snprintf(buf, PATH_MAX - 1, "DETACH DATABASE \"%s\";", dbname);
>>> +	if (ret < 0) {
>>> +		return ret;
>>> +	} else if ((size_t)ret >= sizeof(buf)) {
>>> +		ret = -EINVAL;
>>> +		return ret;
>>> +	}
>>> +
>>> +	/* attach to new DB in filename */
>>> +	ret = sqlite3_exec(dbh, buf, NULL, NULL, &err);
>>> +	if (ret != SQLITE_OK)
>>> +		xlog(L_ERROR, "Unable to detach database %s: %s", dbname, err);
>>> +
>>> +	xlog(D_GENERAL, "Detached database %s", dbname);
>>> +	return ret;
>>> +}
>>> +
>>> +/*
>>> + * Create a client record
>>> + */
>>> +int
>>> +clstate_insert_client(const unsigned char *addr, const unsigned char *clname,
>>> +			const size_t namelen)
>>> +{
>>> +	int ret;
>>> +	char *err = NULL;
>>> +	char dbname[CLSTATE_MAX_ADDRESS_LEN];
>>> +	sqlite3_stmt *stmt = NULL;
>>> +
>>> +	addr_to_dbname((const char *)addr, dbname);
>>> +
>>> +	ret = clstate_db_attach(dbname);
>>> +	if (ret != SQLITE_OK)
>>> +		return ret;
>>> +
>>> +	snprintf(buf, sizeof(buf), "CREATE TABLE IF NOT EXISTS '%s'.clients "
>>> +				   "(id BLOB PRIMARY KEY, time INTEGER);",
>>> +				   dbname);
>>> +	if (ret < 0) {
>>> +		goto out_detach;
>>> +	} else if ((size_t)ret >= sizeof(buf)) {
>>> +		ret = -EINVAL;
>>> +		goto out_detach;
>>> +	}
>>> +
>>> +	ret = sqlite3_exec(dbh, buf, NULL, NULL, &err);
>>> +	if (ret != SQLITE_OK) {
>>> +		xlog(L_ERROR, "Unable to create table: %s", err);
>>> +		goto out_detach;
>>> +	}
>>> +
>>> +	ret = snprintf(buf, sizeof(buf),
>>> +			"INSERT OR REPLACE INTO '%s'.clients VALUES (?, "
>>> +			"strftime('%%s', 'now'));", dbname);
>>> +	if (ret < 0) {
>>> +		goto out_detach;
>>> +	} else if ((size_t)ret >= sizeof(buf)) {
>>> +		ret = -EINVAL;
>>> +		goto out_detach;
>>> +	}
>>> +
>>> +	ret = sqlite3_prepare_v2(dbh, buf, ret + 1, &stmt, NULL);
>>> +	if (ret != SQLITE_OK) {
>>> +		xlog(D_GENERAL, "Statement prepare failed: %d", ret);
>>> +		goto out_err;
>>> +	}
>>> +
>>> +	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
>>> +				SQLITE_STATIC);
>>> +	if (ret != SQLITE_OK) {
>>> +		xlog(D_GENERAL, "Bind blob failed: %d", ret);
>>> +		goto out_err;
>>> +	}
>>> +
>>> +	ret = sqlite3_step(stmt);
>>> +	if (ret == SQLITE_DONE)
>>> +		ret = SQLITE_OK;
>>> +	else
>>> +		xlog(D_GENERAL, "Unexpected return code from insert: %s",
>>> +				sqlite3_errmsg(dbh));
>>> +
>>> +out_err:
>>> +	xlog(D_GENERAL, "%s returning %d", __func__, ret);
>>> +	sqlite3_finalize(stmt);
>>> +	sqlite3_free(err);
>>> +out_detach:
>>> +	clstate_db_detach(dbname);
>>> +	return ret;
>>> +}
>>> diff --git a/utils/clstated/sqlite.h b/utils/clstated/sqlite.h
>>> new file mode 100644
>>> index 0000000..4f81745
>>> --- /dev/null
>>> +++ b/utils/clstated/sqlite.h
>>> @@ -0,0 +1,27 @@
>>> +/*
>>> + * Copyright (C) 2011  Red Hat, Jeff Layton <jlayton@redhat.com>
>>> + *
>>> + * This program is free software; you can redistribute it and/or
>>> + * modify it under the terms of the GNU General Public License
>>> + * as published by the Free Software Foundation; either version 2
>>> + * of the License, or (at your option) any later version.
>>> + *
>>> + * This program is distributed in the hope that it will be useful,
>>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>>> + * GNU General Public License for more details.
>>> + *
>>> + * You should have received a copy of the GNU General Public License
>>> + * along with this program; if not, write to the Free Software
>>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor,
>>> + * Boston, MA 02110-1301, USA.
>>> + */
>>> +
>>> +#ifndef _SQLITE_H_
>>> +#define _SQLITE_H_
>>> +
>>> +void clstate_set_topdir(char *topdir);
>>> +int clstate_maindb_init(void);
>>> +int clstate_insert_client(const unsigned char *addr, const unsigned char *clname, const size_t namelen);
>>> +
>>> +#endif /* _SQLITE_H */
>>> -- 
>>> 1.7.1
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




