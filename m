Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:53234 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757132AbaIKU2o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 16:28:44 -0400
Received: by mail-qc0-f181.google.com with SMTP id r5so1947026qcx.40
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 13:28:39 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 11 Sep 2014 16:28:36 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 5/7] nfsdcltrack: update schema to v2
Message-ID: <20140911162836.70056390@tlielax.poochiereds.net>
In-Reply-To: <20140911195547.GA21296@fieldses.org>
References: <1410193821-25109-1-git-send-email-jlayton@primarydata.com>
	<1410193821-25109-6-git-send-email-jlayton@primarydata.com>
	<20140911195547.GA21296@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 11 Sep 2014 15:55:47 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Sep 08, 2014 at 12:30:19PM -0400, Jeff Layton wrote:
> > From: Jeff Layton <jlayton@poochiereds.net>
> > 
> > In order to allow knfsd's lock manager to lift its grace period early,
> > we need to figure out whether all clients have finished reclaiming
> > their state not. Unfortunately, the current code doesn't allow us to
> > ascertain this. All we track for each client is a timestamp that tells
> > us when the last "check" or "create" operation came in.
> > 
> > We need to track the two timestamps separately. Add a new
> > "reclaim_complete" column to the database that tells us when the last
> > "create" operation came in. For now, we just insert "0" in that column
> > but a later patch will make it so that we insert a real timestamp for
> > v4.1+ client records.
> 
> If I understand correctly, then nfsdcltrack has a bug here: we shouldn't
> be counting a 4.1 client as allowed to reclaim on the next boot until we
> get the RECLAIM_COMPLETE, but nfsdcltrack is allowing a 4.1 client to
> reclaim if all we got the previous boot was a reclaim open (a "check"
> operation).
> 
> --b.
> 

Yeah, I guess so, with a bit of a clarification I think...

We don't want to allow a v4.1 client to reclaim if it didn't send a
RECLAIM_COMPLETE prior to the last reboot *and* the grace period ended
prior to the last reboot.

IOW, in the case where the reboot occurs before the grace period ends,
we don't want to clean out the and deny reclaims. FWIW, the legacy
client tracker got this very wrong -- if you did a couple of rapid
reboots in succession you couldn't reclaim once everything was back up.

I'll have to ponder how best to fix that. Given that the logic required
is quite different between v4.0 and v4.1 clients, we may have to add yet
another column to the DB to track what sort of client this is.

> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  utils/nfsdcltrack/sqlite.c | 102
> > +++++++++++++++++++++++++++++++++++++++++---- 1 file changed, 94
> > insertions(+), 8 deletions(-)
> > 
> > diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
> > index dde2f7ff8621..e260e81b1722 100644
> > --- a/utils/nfsdcltrack/sqlite.c
> > +++ b/utils/nfsdcltrack/sqlite.c
> > @@ -29,7 +29,10 @@
> >   *
> >   * clients: an "id" column containing a BLOB with the long-form
> > clientid as
> >   * 	    sent by the client, a "time" column containing a
> > timestamp (in
> > - * 	    epoch seconds) of when the record was last updated.
> > + * 	    epoch seconds) of when the record was last updated,
> > and a
> > + * 	    "reclaim_complete" column containing a timestamp
> > (in epoch seconds)
> > + * 	    of when the last "create" operation came in for
> > v4.1+ clients.
> > + * 	    v4.0 clients should always have this set to 0.
> >   */
> >  
> >  #ifdef HAVE_CONFIG_H
> > @@ -50,7 +53,7 @@
> >  
> >  #include "xlog.h"
> >  
> > -#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 1
> > +#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 2
> >  
> >  /* in milliseconds */
> >  #define CLTRACK_SQLITE_BUSY_TIMEOUT 10000
> > @@ -120,6 +123,81 @@ out:
> >  	return ret;
> >  }
> >  
> > +static int
> > +sqlite_maindb_update_v1_to_v2(void)
> > +{
> > +	int ret, ret2;
> > +	char *err;
> > +
> > +	/* begin transaction */
> > +	ret = sqlite3_exec(dbh, "BEGIN EXCLUSIVE TRANSACTION;",
> > NULL, NULL,
> > +				&err);
> > +	if (ret != SQLITE_OK) {
> > +		xlog(L_ERROR, "Unable to begin transaction: %s",
> > err);
> > +		goto rollback;
> > +	}
> > +
> > +	/*
> > +	 * Check schema version again. This time, under an
> > exclusive
> > +	 * transaction to guard against racing DB setup attempts
> > +	 */
> > +	ret = sqlite_query_schema_version();
> > +	switch (ret) {
> > +	case 1:
> > +		/* Still at v1 -- do conversion */
> > +		break;
> > +	case CLTRACK_SQLITE_LATEST_SCHEMA_VERSION:
> > +		/* Someone else raced in and set it up */
> > +		ret = 0;
> > +		goto rollback;
> > +	default:
> > +		/* Something went wrong -- fail! */
> > +		ret = -EINVAL;
> > +		goto rollback;
> > +	}
> > +
> > +	/* create v2 clients table */
> > +	ret = sqlite3_exec(dbh, "ALTER TABLE clients ADD COLUMN "
> > +				"reclaim_complete INTEGER;",
> > +				NULL, NULL, &err);
> > +	if (ret != SQLITE_OK) {
> > +		xlog(L_ERROR, "Unable to update clients table:
> > %s", err);
> > +		goto rollback;
> > +	}
> > +
> > +	ret = snprintf(buf, sizeof(buf), "UPDATE parameters SET
> > value = %d "
> > +			"WHERE key = \"version\";",
> > +			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION);
> > +	if (ret < 0) {
> > +		xlog(L_ERROR, "sprintf failed!");
> > +		goto rollback;
> > +	} else if ((size_t)ret >= sizeof(buf)) {
> > +		xlog(L_ERROR, "sprintf output too long! (%d
> > chars)", ret);
> > +		ret = -EINVAL;
> > +		goto rollback;
> > +	}
> > +
> > +	ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL,
> > &err);
> > +	if (ret != SQLITE_OK) {
> > +		xlog(L_ERROR, "Unable to update schema version:
> > %s", err);
> > +		goto rollback;
> > +	}
> > +
> > +	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL,
> > &err);
> > +	if (ret != SQLITE_OK) {
> > +		xlog(L_ERROR, "Unable to commit transaction: %s",
> > err);
> > +		goto rollback;
> > +	}
> > +out:
> > +	sqlite3_free(err);
> > +	return ret;
> > +rollback:
> > +	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL,
> > NULL, &err);
> > +	if (ret2 != SQLITE_OK)
> > +		xlog(L_ERROR, "Unable to rollback transaction:
> > %s", err);
> > +	goto out;
> > +}
> > +
> >  /*
> >   * Start an exclusive transaction and recheck the DB schema
> > version. If it's
> >   * still zero (indicating a new database) then set it up. If that
> > all works, @@ -127,9 +205,9 @@ out:
> >   * transaction. On any error, rollback the transaction.
> >   */
> >  int
> > -sqlite_maindb_init_v1(void)
> > +sqlite_maindb_init_v2(void)
> >  {
> > -	int ret;
> > +	int ret, ret2;
> >  	char *err = NULL;
> >  
> >  	/* Start a transaction */
> > @@ -169,7 +247,7 @@ sqlite_maindb_init_v1(void)
> >  
> >  	/* create the "clients" table */
> >  	ret = sqlite3_exec(dbh, "CREATE TABLE clients (id BLOB
> > PRIMARY KEY, "
> > -				"time INTEGER);",
> > +				"time INTEGER, reclaim_complete
> > INTEGER);", NULL, NULL, &err);
> >  	if (ret != SQLITE_OK) {
> >  		xlog(L_ERROR, "Unable to create clients table:
> > %s", err); @@ -207,7 +285,9 @@ out:
> >  
> >  rollback:
> >  	/* Attempt to rollback the transaction */
> > -	sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL,
> > &err);
> > +	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL,
> > NULL, &err);
> > +	if (ret2 != SQLITE_OK)
> > +		xlog(L_ERROR, "Unable to rollback transaction:
> > %s", err); goto out;
> >  }
> >  
> > @@ -255,9 +335,15 @@ sqlite_prepare_dbh(const char *topdir)
> >  		/* DB is already set up. Do nothing */
> >  		ret = 0;
> >  		break;
> > +	case 1:
> > +		/* Old DB -- update to new schema */
> > +		ret = sqlite_maindb_update_v1_to_v2();
> > +		if (ret)
> > +			goto out_close;
> > +		break;
> >  	case 0:
> >  		/* Query failed -- try to set up new DB */
> > -		ret = sqlite_maindb_init_v1();
> > +		ret = sqlite_maindb_init_v2();
> >  		if (ret)
> >  			goto out_close;
> >  		break;
> > @@ -289,7 +375,7 @@ sqlite_insert_client(const unsigned char
> > *clname, const size_t namelen) sqlite3_stmt *stmt = NULL;
> >  
> >  	ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO
> > clients VALUES "
> > -				      "(?, strftime('%s',
> > 'now'));", -1,
> > +					"(?, strftime('%s',
> > 'now'), 0);", -1, &stmt, NULL);
> >  	if (ret != SQLITE_OK) {
> >  		xlog(L_ERROR, "%s: insert statement prepare
> > failed: %s", -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
