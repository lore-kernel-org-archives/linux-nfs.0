Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42071 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962Ab0FWVcJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 17:32:09 -0400
Date: Thu, 24 Jun 2010 07:31:57 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH] Improve support for exporting btrfs subvolumes.
Message-ID: <20100624073157.743983ec@notabene.brown>
In-Reply-To: <20100623182837.GB28346@fieldses.org>
References: <19481.43625.476833.275104@notabene.brown>
	<20100623182837.GB28346@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 23 Jun 2010 14:28:38 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jun 17, 2010 at 02:54:01PM +1000, Neil Brown wrote:
> > 
> > If you export two subvolumes of a btrfs filesystem, they will both be
> > given the same uuid so lookups will be confused.
> > blkid cannot differentiate the two, so we must use the fsid from
> > statfs64 to identify the filesystem.
> > 
> > We cannot tell if blkid or statfs is best without knowing internal
> > details of the filesystem in question, so we need to encode specific
> > knowledge of btrfs in mountd.  This is unfortunate.
> > 
> > To ensure smooth handling of this and possible future changes in uuid
> > generation, we add infrastructure for multiple different uuids to be
> > recognised on old filehandles, but only the preferred on is used on
> > new filehandles.
> 
> Could you just contatenate the two (or hash them somehow)?  Or does that
> just use up too much space in the filehandle?

I did consider xoring them together but came to the conclusion that would
actually be a regression.
If you look down at the comment that I included in uuid_by_path, you will see
that some filesystems (e.g. VFAT) just use the major/minor device number for
the f_fsid from statfs.  As you know that is not necessarily stable over
reboots, while the UUID that blkid gives is.
So if we always adding the two uuids somehow, it would be an improvement for
btrfs, no change for e.g. ext3/XFS, and a regression for VFAT (and others I
think).  Not good.

Thanks,
NeilBrown


> 
> --b.
> 
> > 
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > 
> > --
> > This is a substantially revised version of a patch I posted a while
> > ago.
> > I tried to find a way to do it would hard coding knowledge of btrfs in
> > nfs-utils, but it isn't possible.  For some filesystems, f_fsid is
> > best, for some it is worst.  No way to tell the difference.
> > 
> > This patch add infrastructure so that if we find a better way to get a
> > good uuid (e.g. a new syscall), we can slot it in for new filehandles,
> > but old filehandles using the old uuid will still work.
> > 
> > I believe this is ready for inclusion upstream.
> > Thanks,
> > NeilBrown
> > 
> > 
> > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> > index caef5b2..85cd829 100644
> > --- a/utils/mountd/cache.c
> > +++ b/utils/mountd/cache.c
> > @@ -170,13 +170,16 @@ void auth_unix_gid(FILE *f)
> >  #if USE_BLKID
> >  static const char *get_uuid_blkdev(char *path)
> >  {
> > +	/* We set *safe if we know that we need the
> > +	 * fsid from statfs too.
> > +	 */
> >  	static blkid_cache cache = NULL;
> >  	struct stat stb;
> >  	char *devname;
> >  	blkid_tag_iterate iter;
> >  	blkid_dev dev;
> >  	const char *type;
> > -	const char *val = NULL;
> > +	const char *val, *uuid = NULL;
> >  
> >  	if (cache == NULL)
> >  		blkid_get_cache(&cache, NULL);
> > @@ -193,42 +196,29 @@ static const char *get_uuid_blkdev(char *path)
> >  	iter = blkid_tag_iterate_begin(dev);
> >  	if (!iter)
> >  		return NULL;
> > -	while (blkid_tag_next(iter, &type, &val) == 0)
> > +	while (blkid_tag_next(iter, &type, &val) == 0) {
> >  		if (strcmp(type, "UUID") == 0)
> > +			uuid = val;
> > +		if (strcmp(type, "TYPE") == 0 &&
> > +		    strcmp(val, "btrfs") == 0) {
> > +			uuid = NULL;
> >  			break;
> > +		}
> > +	}
> >  	blkid_tag_iterate_end(iter);
> > -	return val;
> > +	return uuid;
> >  }
> >  #else
> >  #define get_uuid_blkdev(path) (NULL)
> >  #endif
> >  
> > -int get_uuid(char *path, char *uuid, int uuidlen, char *u)
> > +int get_uuid(const char *val, int uuidlen, char *u)
> >  {
> >  	/* extract hex digits from uuidstr and compose a uuid
> >  	 * of the given length (max 16), xoring bytes to make
> > -	 * a smaller uuid.  Then compare with uuid
> > +	 * a smaller uuid.
> >  	 */
> >  	int i = 0;
> > -	const char *val = NULL;
> > -	char fsid_val[17];
> > -
> > -	if (path) {
> > -		val = get_uuid_blkdev(path);
> > -		if (!val) {
> > -			struct statfs64 st;
> > -
> > -			if (statfs64(path, &st))
> > -				return 0;
> > -			if (!st.f_fsid.__val[0] && !st.f_fsid.__val[1])
> > -				return 0;
> > -			snprintf(fsid_val, 17, "%08x%08x",
> > -				 st.f_fsid.__val[0], st.f_fsid.__val[1]);
> > -			val = fsid_val;
> > -		}
> > -	} else {
> > -		val = uuid;
> > -	}
> >  	
> >  	memset(u, 0, uuidlen);
> >  	for ( ; *val ; val++) {
> > @@ -252,6 +242,60 @@ int get_uuid(char *path, char *uuid, int uuidlen, char *u)
> >  	return 1;
> >  }
> >  
> > +int uuid_by_path(char *path, int type, int uuidlen, char *uuid)
> > +{
> > +	/* get a uuid for the filesystem found at 'path'.
> > +	 * There are several possible ways of generating the
> > +	 * uuids (types).
> > +	 * Type 0 is used for new filehandles, while other types
> > +	 * may be used to interpret old filehandle - to ensure smooth
> > +	 * forward migration.
> > +	 * We return 1 if a uuid was found (and it might be worth 
> > +	 * trying the next type) or 0 if no more uuid types can be
> > +	 * extracted.
> > +	 */
> > +
> > +	/* Possible sources of uuid are
> > +	 * - blkid uuid
> > +	 * - statfs64 uuid
> > +	 *
> > +	 * On some filesystems (e.g. vfat) the statfs64 uuid is simply an
> > +	 * encoding of the device that the filesystem is mounted from, so
> > +	 * it we be very bad to use that (as device numbers change).  blkid
> > +	 * must be preferred.
> > +	 * On other filesystems (e.g. btrfs) the statfs64 uuid contains
> > +	 * important info that the blkid uuid cannot contain:  This happens
> > +	 * when multiple subvolumes are exported (they have the same
> > +	 * blkid uuid but different statfs64 uuids).
> > +	 * We rely on get_uuid_blkdev *knowing* which is which and not returning
> > +	 * a uuid for filesystems where the statfs64 uuid is better.
> > +	 *
> > +	 */
> > +	struct statfs64 st;
> > +	char fsid_val[17];
> > +	const char *blkid_val;
> > +	const char *val;
> > +
> > +	blkid_val = get_uuid_blkdev(path);
> > +
> > +	if (statfs64(path, &st) == 0 &&
> > +	    (st.f_fsid.__val[0] || st.f_fsid.__val[1]))
> > +		snprintf(fsid_val, 17, "%08x%08x",
> > +			 st.f_fsid.__val[0], st.f_fsid.__val[1]);
> > +	else
> > +		fsid_val[0] = 0;
> > +
> > +	if (blkid_val && (type--) == 0)
> > +		val = blkid_val;
> > +	else if (fsid_val[0] && (type--) == 0)
> > +		val = fsid_val;
> > +	else
> > +		return 0;
> > +
> > +	get_uuid(val, uuidlen, uuid);
> > +	return 1;
> > +}
> > +
> >  /* Iterate through /etc/mtab, finding mountpoints
> >   * at or below a given path
> >   */
> > @@ -398,6 +442,7 @@ void nfsd_fh(FILE *f)
> >  			struct stat stb;
> >  			char u[16];
> >  			char *path;
> > +			int type;
> >  
> >  			if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT) {
> >  				static nfs_export *prev = NULL;
> > @@ -461,10 +506,14 @@ void nfsd_fh(FILE *f)
> >  					continue;
> >  			check_uuid:
> >  				if (exp->m_export.e_uuid)
> > -					get_uuid(NULL, exp->m_export.e_uuid,
> > +					get_uuid(exp->m_export.e_uuid,
> >  						 uuidlen, u);
> > -				else if (get_uuid(path, NULL, uuidlen, u) == 0)
> > -					continue;
> > +				else
> > +					for (type = 0;
> > +					     uuid_by_path(path, type, uuidlen, u);
> > +					     type++)
> > +						if (memcmp(u, fhuuid, uuidlen) != 0)
> > +							break;
> >  
> >  				if (memcmp(u, fhuuid, uuidlen) != 0)
> >  					continue;
> > @@ -600,13 +649,13 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
> >  		write_secinfo(f, exp, flag_mask);
> >   		if (exp->e_uuid == NULL || different_fs) {
> >   			char u[16];
> > - 			if (get_uuid(path, NULL, 16, u)) {
> > + 			if (uuid_by_path(path, 0, 16, u)) {
> >   				qword_print(f, "uuid");
> >   				qword_printhex(f, u, 16);
> >   			}
> >   		} else {
> >   			char u[16];
> > - 			get_uuid(NULL, exp->e_uuid, 16, u);
> > + 			get_uuid(exp->e_uuid, 16, u);
> >   			qword_print(f, "uuid");
> >   			qword_printhex(f, u, 16);
> >   		}
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

