From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH V2] make "noac" and "actimeo=0" work correctly
Date: Thu, 10 Jul 2008 11:58:58 -0400
Message-ID: <76bd70e30807100858g58fbf454uc9331035a2bbf264@mail.gmail.com>
References: <484EE994.5030907@redhat.com> <487390EC.7080403@redhat.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "NFS list" <linux-nfs@vger.kernel.org>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>
To: "Peter Staubach" <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:17341 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbYGJP7D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 11:59:03 -0400
Received: by gv-out-0910.google.com with SMTP id e6so654086gvc.37
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2008 08:58:59 -0700 (PDT)
In-Reply-To: <487390EC.7080403@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Peter-

On Tue, Jul 8, 2008 at 12:08 PM, Peter Staubach <staubach@redhat.com> wrote:
> Hi.
>
> I've been looking at a bugzilla which describes a problem where
> a customer was advised to use either the "noac" or "actimeo=0"
> mount options to solve a consistency problem that they were
> seeing in the file attributes.  It turned out that this solution
> did not work reliably for them because sometimes, the local
> attribute cache was believed to be valid and not timed out.
> (With an attribute cache timeout of 0, the cache should always
> appear to be timed out.)
>
> In looking at this situation, it appears to me that the problem
> is that the attribute cache timeout code has an off-by-one
> error in it.  It is assuming that the cache is valid in the
> region, [read_cache_jiffies, read_cache_jiffies + attrtimeo].  The
> cache should be considered valid only in the region,
> [read_cache_jiffies, read_cache_jiffies + attrtimeo).  With this
> change, the options, "noac" and "actimeo=0", work as originally
> expected.
>
> While I was there, I addressed a problem with the jiffies
> overflowing on 32 bit systems.  When overflow occurs, the
> value of read_cache_jiffies + attrtimeo can be less then the
> value of read_cache_jiffies.  This would cause an unnecessary
> GETATTR over the wire.
>
> Thoughts and/or comments?  This is an updated patch which includes
> the previous support which was added to correct the noac/actimeo=0
> handling.

A couple of random thoughts below.

> Signed-off-by: Peter Staubach <staubach@redhat.com>
>
>
> --- linux-2.6.25.i686/fs/nfs/dir.c.org
> +++ linux-2.6.25.i686/fs/nfs/dir.c
> @@ -1808,7 +1808,7 @@ static int nfs_access_get_cached(struct
>        cache = nfs_access_search_rbtree(inode, cred);
>        if (cache == NULL)
>                goto out;
> -       if (!time_in_range(jiffies, cache->jiffies, cache->jiffies +
> nfsi->attrtimeo))
> +       if (!nfs_time_in_range_open(jiffies, cache->jiffies, cache->jiffies
> + nfsi->attrtimeo))
>                goto out_stale;
>        res->jiffies = cache->jiffies;
>        res->cred = cache->cred;
> --- linux-2.6.25.i686/fs/nfs/inode.c.org
> +++ linux-2.6.25.i686/fs/nfs/inode.c
> @@ -706,14 +706,7 @@ int nfs_attribute_timeout(struct inode *
>
>        if (nfs_have_delegation(inode, FMODE_READ))
>                return 0;
> -       /*
> -        * Special case: if the attribute timeout is set to 0, then always
> -        *               treat the cache as having expired (unless holding
> -        *               a delegation).
> -        */
> -       if (nfsi->attrtimeo == 0)
> -               return 1;
> -       return !time_in_range(jiffies, nfsi->read_cache_jiffies,
> nfsi->read_cache_jiffies + nfsi->attrtimeo);
> +       return !nfs_time_in_range_open(jiffies, nfsi->read_cache_jiffies,
> nfsi->read_cache_jiffies + nfsi->attrtimeo);
>  }
>
>  /**
> @@ -1098,7 +1091,7 @@ static int nfs_update_inode(struct inode
>                nfsi->attrtimeo_timestamp = now;
>                nfsi->last_updated = now;
>        } else {
> -               if (!time_in_range(now, nfsi->attrtimeo_timestamp,
> nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
> +               if (!nfs_time_in_range_open(now, nfsi->attrtimeo_timestamp,
> nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
>                        if ((nfsi->attrtimeo <<= 1) >
> NFS_MAXATTRTIMEO(inode))
>                                nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
>                        nfsi->attrtimeo_timestamp = now;
> --- linux-2.6.25.i686/include/linux/nfs_fs.h.org
> +++ linux-2.6.25.i686/include/linux/nfs_fs.h
> @@ -121,7 +121,7 @@ struct nfs_inode {
>         *
>         * We need to revalidate the cached attrs for this inode if
>         *
> -        *      jiffies - read_cache_jiffies > attrtimeo
> +        *      jiffies - read_cache_jiffies >= attrtimeo
>         */
>        unsigned long           read_cache_jiffies;
>        unsigned long           attrtimeo;
> @@ -244,6 +244,22 @@ static inline unsigned NFS_MAXATTRTIMEO(
>        return S_ISDIR(inode->i_mode) ? nfss->acdirmax : nfss->acregmax;
>  }
>
> +static inline int nfs_time_in_range_open(unsigned long a,
> +                               unsigned long b, unsigned long c)

All of nfs_time_in_range_open's callers use a sum of 'b' and
'nfsi->attrtimeo' for 'c'.  Would it be cleaner to pass in
nfsi->attrtimeo' rather than 'b + nfsi->attrtimeo' and do the sum
here?  It might make sense to explicitly check nfsi->attrtimeo for
zero here to document the special behavior of "actimeo=0".

Alternately, checking explicitly if b and c are equal might accomplish
the same without changing the synopsis.

Also, all of nfs_time_in_range_open's callers negate the return value.
 Would the code in the callers be cleaner if that negation was moved
into nfs_time_in_range_open?  You might rename
nfs_time_in_range_open() as nfs_cache_has_expired(), for example, to
make the 'if' statements in the callers make sense in English.

My feeling is that if you have to sit and stare at this for 5 minutes
to understand precisely how it works, it has already become too
obfuscated.  In addition to fixing any bugs, I wonder if we can make
it easier to understand and maintain as well.

> +{
> +       /*
> +        * If c is less then b, then the jiffies have wrapped.
> +        * If so, then check to see if a is between b and the
> +        * max jiffies value or between 0 and the value of c.
> +        * This is the range between b and c.

include/linux/jiffies.h claims it handles jiffy wrapping correctly.
Why isn't time_in_range() sufficient if 'c' has wrapped?  If it isn't,
should you fix time_in_range() too?

You could then simplify this to "return b != c && time_in_range(a, b,
c);" or something like that.  Or if you negate the return value here:

static inline nfs_attributes_have_expired(unsigned long current,
                                                         unsigned long
start, unsigned long end)
{
        return (start == end) || !time_in_range(current, start, end);
}

My 0.02USD.

> +        *
> +        * Otherwise, just check to see whether a is in [b, c).
> +        */
> +       if (c < b)
> +               return time_after_eq(a, b) || time_before(a, c);
> +       return time_after_eq(a, b) && time_before(a, c);
> +}
> +
>  static inline int NFS_STALE(const struct inode *inode)
>  {
>        return test_bit(NFS_INO_STALE, &NFS_I(inode)->flags);

-- 
Chuck Lever
