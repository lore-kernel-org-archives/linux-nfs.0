From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 2/5] NLM failover - per fs grace period
Date: Fri, 18 Aug 2006 19:49:21 +1000
Message-ID: <1155894561.17651.442.camel@hole.melbourne.sgi.com>
References: <1155535221.3416.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GE0yr-0003CH-QI
	for nfs@lists.sourceforge.net; Fri, 18 Aug 2006 02:49:34 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GE0yq-00067F-Ty
	for nfs@lists.sourceforge.net; Fri, 18 Aug 2006 02:49:34 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1155535221.3416.26.camel@localhost.localdomain>
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

On Mon, 2006-08-14 at 16:00, Wendy Cheng wrote:
> This change enables per NFS-export entry lockd grace period.[...]

>  
> +/* Server fsid linked list for NLM lock failover */
> +struct nlm_serv {
> +	struct nlm_serv*	s_next;		/* linked list */
> +	unsigned long		s_grace_period;	/* per fsid grace period */
> +	int			s_fsid;		/* export fsid */
> +};
> +

The name of this structure appears to be left over from your
previous approach; it doesn't really represent a server anymore.
Giving the structure, and list, and the lock that protects it
similar and appropriate names might be nice.

Also, the s_grace_period field isn't actually a period, it's
the future expiry time expressed in jiffies.  The field name
and comment are both confusing.

> +int
> +nlmsvc_fo_setgrace(int fsid)
> +{
> +	struct nlm_serv *per_fsid, *entry;
> +
> +	/* allocate the entry */
> +	per_fsid = kmalloc(sizeof(struct nlm_serv), GFP_KERNEL);
> +	if (per_fsid == NULL) {
> +		printk("lockd: nlmsvc_fo_setgrace kmalloc fails\n");
> +		return(-ENOMEM);
> +	}
> +

These actions:

# echo 1234 > /proc/fs/nfsd/nlm_set_igrace
# echo 1234 > /proc/fs/nfsd/nlm_set_igrace

result in two separate nlm_serv structures being allocated and
stored in the global list.  That doesn't make sense, a filesystem
should have at most one grace period.

> +	/* link into the global list */
> +	spin_lock(&nlm_fo_lock);
> +	
> +	entry = nlm_servs;
> +	per_fsid->s_next = entry;
> +	nlm_servs = per_fsid;

Why use opencoded list manipulation when Linux has a adequate
list package in <linux/list.h> ?

> +
> +	/* done */
> +	spin_unlock(&nlm_fo_lock);
> +	return 0;
> +}
> +
> +/* nlm_servs gargabe collection 

s/gargabe/garbage/

> + *  - caller should hold nlm_ip_mutex

This comment is stale, you don't have an nlm_ip_mutex anymore.

> +void 
> +nlmsvc_fo_reset_servs()
> +{
> [...]
> +	return;

This "return" is superfluous.

> +int
> +nlmsvc_fo_check(struct nfs_fh *fh)
> +{
> +	struct nlm_serv **e_top, *e_this, *e_purge=NULL;
> +	int rc=0, this_fsid, not_found;
> +
> +	spin_lock(&nlm_fo_lock);
> +
> +	/* no failover entry */
> +	if (!(e_this = nlm_servs))  
> +		goto nlmsvc_fo_check_out;
> +
> +	/* see if this fh has fsid */
> +	not_found = nlm_fo_get_fsid(fh, &this_fsid);
> +	if (not_found) 
> +		goto nlmsvc_fo_check_out;

You could do this outside the critical section.

> +
> +	/* check to see whether this_fsid is in nlm_servs list */
> +	e_top = &nlm_servs;
> +	while (e_this) {
> +		if (time_before(e_this->s_grace_period, jiffies)) {
> +			dprintk("lockd: fsid=%d grace period expires\n",
> +				e_this->s_fsid);
> +			e_purge = e_this;
> +			break;
> +		} else if (e_this->s_fsid == this_fsid) {
> +			dprintk("lockd: fsid=%d in grace period\n",
> +				e_this->s_fsid);
> +			rc = 1;
> +		}
> +		e_top = &(e_this->s_next);
> +		e_this = e_this->s_next;
> +	}
> +
> +	/* piggy back nlm_servs garbage collection */
> +	if (e_purge) {
> +		*e_top = NULL;
> +		__nlm_servs_gc(e_purge);
> +	}
> +

So...if you find an expired entry, you delete entries from the global
list starting at that entry and continuing to the end.  Presumably the
assumption here is that the list is sorted in decreasing order of expiry
time, because you only prepend to the list in nlmsvc_fo_setgrace().

However that's wrong: the expiry times returned from set_grace_period()
don't have to monotonically increase.  Both nlm_grace_period and
nlm_timeout may be changed by sysctls, so the length of the grace
period can vary.  If it varies downwards between two writes to the
set_igrace file, the list may not be in the order you expect.

Also, if your userspace program went beserk and started writing
random fsids into the set_igrace file, they wouldn't be purged
until lockd is shut down or the first NLM call arrives *after*
their grace expires.  This has the potential for a kernel memory
Denial of Service attack.  Perhaps, when you add a new entry you
could also purge expired ones, and/or put an arbitrary limit on
how large the list can grow?


>  static ssize_t (*write_op[])(struct file *, char *, size_t) = {
>  	[NFSD_Svc] = write_svc,
> @@ -104,6 +106,7 @@ static ssize_t (*write_op[])(struct file
>  	[NFSD_Getfs] = write_getfs,
>  	[NFSD_Fh] = write_filehandle,
>  	[NFSD_Nlm_unlock] = do_nlm_fo_unlock,
> +	[NFSD_Nlm_igrace] = do_nlm_fs_grace,
>  	[NFSD_Threads] = write_threads,
>  	[NFSD_Versions] = write_versions,
>  #ifdef CONFIG_NFSD_V4

Same comment as before.

> +extern struct nlm_serv *nlm_servs;
> +
> +static inline int
> +nlmsvc_fo_grace_period(struct nlm_args *argp)
> +{
> +	if (unlikely(nlm_servs))
> +		return(nlmsvc_fo_check(&argp->lock.fh));
> +
> +	return 0;
> +}
> +

You have two nearly identical functions to do this, which seems
superfluous.  This is why we have header files.

> @@ -81,7 +81,6 @@ static unsigned long set_grace_period(vo
>  				/ nlm_timeout) * nlm_timeout * HZ;
>  	else
>  		grace_period = nlm_timeout * 5 * HZ;
> -	nlmsvc_grace_period = 1;
>  	return grace_period + jiffies;
>  }

As set_grace_period() no longer sets anything, and returns
an expiry time rather than a period, it's name isn't very
appropriate anymore.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
