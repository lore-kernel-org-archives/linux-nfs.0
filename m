From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect
	sub-second	timestamps on etab
Date: Thu, 26 Apr 2007 07:50:00 -0400
Message-ID: <20070426114959.GA24800@dantu.rdu.redhat.com>
References: <20070425173918.GB6696@salusa.poochiereds.net>
	<17968.12186.298789.226396@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh2U9-0002Ix-J2
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 04:50:05 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hh2UB-0002d2-PQ
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 04:50:08 -0700
In-Reply-To: <17968.12186.298789.226396@notabene.brown>
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

On Thu, Apr 26, 2007 at 02:50:34PM +1000, Neil Brown wrote:
> On Wednesday April 25, jlayton@redhat.com wrote:
> 
> Hi Jeff,
> 
> > Currently, when auth_reload is called, it only looks at the tv_sec field
> > of the mtime when deciding whether to invalidate the exports cache. It's
> > fairly simple to fool this by doing something like:
> > 
> > # exportfs -rv && rpc.mountd && exportfs -uva && exportfs -iv -o no_root_squash,rw 127.0.0.1:/foo
> 
> Yes... real problem.  Not sure I like your solution.
> It obviously helps but it isn't complete (e.g. if filesystem only has
> 1-second resolution) and I think we can do better.
> 
> You can trade performance for accuracy by checking the current time as
> well.
> Something like:
> 
>    now = time(0);
>    stat(_PATH_ETAB, &stb);
> 
>    if (stb.st_mtime < last_loaded)
> 	return;
>    last_loaded = now;
>    // read file.
> 
> That way if the file gets changed, we then read the file every time we
> want information until the second changes.  Then we read it once
> more and hold on to that copy.
> This might mean we read it several times in one second when only one
> update was made, but at least it means we never miss an update.
> 
> Of course if the filesystem does provide better resolution, we should
> use that, but we can only use it if we know that the resolution is -
> and I don't think it is easy to extract that information.
> 
> But! We can get some hints from 'atime'.  I think it safe to assume
> that the resolution of atime is the same as that of ctime. so maybe
> something like:
> 
>     stat(_PATH_ETAB, &stb);
>     if (tspec_cmp(last_loaded, stb.st_mtim) < 0)
> 		return;
>     last_loaded = stb.st_atim;
> 
> (excuse the pseudo-code.  Assume tspec_cmp compares struct timespec
>  with return value similar to strcmp).
> 
> Here, 'last_loaded' represents a time period of a size which matches
> the time-resolution of the filesystem.  We know that time period ends
> after the last time the file was modified, and it begins before the
> last time we read the file.
> If it is after the time-period when the file was change, we don't need
> to read the file again, otherwise we do.
> 
> Now if the filesystem as mounted with noatime, this will leave us
> always re-reading the file, so we need to assume a minimum resolution
> of 1 second, and if atime < now, update atime to equal now.
> 
> And if the system clock was pushed back substantially, we would not
> read the file until after it had caught up again, so we better leave the
> "== last_modified" test in there.
> 
> 
> Or maybe we could just note that 'exportfs' always replaced the file
> when it updates it, and just check to see if the inode number is
> different... though inode number re-use will defeat that (ext3
> alternated between two) and we don't have access to a generation
> number... better stick with time stamps.
> 
> So I would like the propose the following enhancement of your patch.
> 
> Do you agree?
> 
> Thanks,
> NeilBrown
> 
> diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
> index 183c9ea..7c99ee3 100644
> --- a/utils/mountd/auth.c
> +++ b/utils/mountd/auth.c
> @@ -46,24 +46,44 @@ auth_init(char *exports)
>  	xtab_mount_write();
>  }
>  
> -time_t
> +struct timespec
>  auth_reload()
>  {
> +	/* "load_loaded" is an estimate of the last time we
> +	 * read the file, and importantly has the same resolution as
> +	 * the filesystem stores timestamps in.  We only avoid reading
> +	 * if last_loaded is certain to be after the last time the file
> +	 * was modified.
> +	 * "last_modified" is used to guard against the system clock being
> +	 * set back, which would confuse the last_loaded calculations.
> +	 */
>  	struct stat		stb;
> -	static time_t		last_modified = 0;
> +	static struct timespec	last_modified;
> +	static struct timespec	last_loaded;
> +	time_t			now = time(0);
>  
>  	if (stat(_PATH_ETAB, &stb) < 0)
>  		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
> -	if (stb.st_mtime == last_modified)
> -		return last_modified;
> -	last_modified = stb.st_mtime;
> +
> +	if (timespec_cmp(&stb.st_mtim, &last_loaded) < 0 &&
> +	    timespec_cmp(&stb.st_mtim, &last_modified) == 0)
> +		return last_loaded;
> +
> +	last_loaded = stb.st_atim;
> +	last_modified = stb.st_mtim;
> +
> +	/* careful of -o noatime */
> +	if (last_loaded.tv_sec < now) {
> +		last_loaded.tv_sec = now;
> +		last_loaded.tv_nsec = 0;
> +	}
>  
>  	export_freeall();
>  	memset(&my_client, 0, sizeof(my_client));
>  	// export_read(export_file);
>  	xtab_export_read();
>  
> -	return last_modified;
> +	return last_loaded;
>  }
>  
>  static nfs_export *
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index 04141d1..c16f344 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -465,15 +465,15 @@ static exports
>  get_exportlist(void)
>  {
>  	static exports		elist = NULL;
> -	static time_t		etime = 0;
> -	time_t			atime;
> +	static struct timespec	etime;
> +	struct timespec		atime;
>  	struct exportnode	*e, *ne;
>  	struct groupnode	*g, *ng, *c, **cp;
>  	nfs_export		*exp;
>  	int			i;
>  
>  	atime = auth_reload();
> -	if (elist && atime == etime)
> +	if (elist && timespec_cmp(&atime, &etime) == 0)
>  		return elist;
>  
>  	etime = atime;
> diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
> index b539278..3a780fa 100644
> --- a/utils/mountd/mountd.h
> +++ b/utils/mountd/mountd.h
> @@ -40,7 +40,16 @@ bool_t		mount_mnt_3_svc(struct svc_req *, dirpath *, mountres3 *);
>  
>  void		mount_dispatch(struct svc_req *, SVCXPRT *);
>  void		auth_init(char *export_file);
> -time_t		auth_reload(void);
> +
> +static inline long int timespec_cmp(struct timespec *t1, struct timespec *t2)
> +{
> +	if (t1->tv_sec == t2->tv_sec)
> +		return t1->tv_nsec - t2->tv_nsec;
> +	else
> +		return t1->tv_sec - t2->tv_sec;
> +}
> +
> +struct timespec	auth_reload(void);
>  nfs_export *	auth_authenticate(char *what, struct sockaddr_in *sin,
>  					char *path);
>  void		auth_export(nfs_export *exp);

No quarrel with your modification of the patch. It does seem like it would
close some holes in mine. That said, I'm starting to think that either Chuck's
suggestion to use inotify or your suggestion to hold the file open might be
a better way to go here. Let me think on that and I'll respond to the other
thread...

-- Jeff


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
