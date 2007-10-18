From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Interesting problem with sunrpc cache
Date: Thu, 18 Oct 2007 10:55:49 -0400
Message-ID: <20071018145549.GA24088@fieldses.org>
References: <1192715235.7466.13.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1192715235.7466.13.camel@moss-terrapins.epoch.ncsc.mil>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Oct 18, 2007 at 09:47:15AM -0400, David P. Quigley wrote:
> Hello,
>     I have been working on a Domain of Interpretation mapper for the
> labeled nfs work and I seem to have hit a wall. I started with idmapd as
> a base and proceeded to modify it to work with DOIs instead. Because of
> this with a few minor exceptions I expected everything to work. For the
> most part it does however I seem to have a minor problem with the cache
> on the nfsd side.
> 
>     I am running into a problem where I can't mount the export because
> the server keeps trying to translate the label. I initially get a
> success but then it repeatedly attempts to retry.

So you're just getting repeated NFS4ERR_DELAY responses to the same
request from the client?  Or does the server just stop responding?  Is
this always reproduceble?

> I have tracked it down to a bit of code which essentially is a
> duplication of do_idmap_lookup_nowait.

When exactly does the label translation occur?

The idmapper is the only server cache that uses this custom
deferral/revisit code.  We did it because currently deferrals require
setting aside the whole compound and then reprocessing it later.  Since
a getattr (possibly including file owners, requiring idmapping) seemed
likely to occur after a nonidempotent operation, this seemed like a bad
idea.

But the solution in nfs4idmap.c is a little ugly and idmapper-specific.
(There are also some (much less likely) races that could occur due to
the export-related upcalls).  Also, if your DOI translation typically
only happens at the beginning of a compound (for example), then may
never see this problem anyway.

I think the real solution is to augment the existing
svc_defer/svc_revisit to allow us to store a lot more state so we don't
have to start the compound processing over from scratch each time.  It
shouldn't be hard.  The problem is more that I don't know how to measure
the improvement.  And at some point I wonder what we'll save by storing
all this other state, just to save a kernel task.  Are tasks really that
expensive?

But anyway, it'd still be interesting to understand this bug since it's
likely to be a bug in the nfs4idmap.c as well.

> In this function we set ret to -ETIMEDOUT which
> is -110 and then we test three conditions. The conditional checks if the
> cache entry has the CACHE_VALID bit set, that the epiration time hasn't
> lapsed and that the flush time hasn't lapsed. The last two conditions
> here are true so I have determined it is because the CACHE_VALID bit
> isn't being set properly. 

Right, so there could be odd race conditions in the custom defer/revisit
code, but as long as CACHE_VALID eventually gets set you'd think it'd
recover.  Perhaps there's more than one cache item involved?

>     This lead me to check deeper into where this bit is set. The answer
> to this is that it should be set inside sunrpc_cache_update using the
> cache_fresh_locked function. Entering this function we hit the two
> conditions up top where it says that the valid bit isn't set and we
> update it directly. The line below should update the valid bit since the
> internals of cache_fresh_locked just set the expiry_time entry of cache
> head and then use test_and_set_bit to set the CACHE_VALID bit in the
> cache head's flags.
> 
> is_new = cache_fresh_locked(old, new->expiry_time);
> 
>     I am very perplexed why something like this is happening. I've been
> trying to figure it out for the better part of a week and I have finally
> hit the wall at this point. Has anyone else encountered this problem or
> have any insight into why this might happen.

I don't have any bright ideas right now, sorry.

--b.
