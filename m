From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] nfsd: only set file_lock.fl_lmops
	in nfsd4_lockt if a stateowner is found
Date: Tue, 27 Jan 2009 17:33:25 -0500
Message-ID: <20090127223325.GK9151@fieldses.org>
References: <1232651764-10799-1-git-send-email-jlayton@redhat.com>
	<1232651764-10799-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1232651764-10799-3-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2009 at 02:16:04PM -0500, Jeff Layton wrote:
> nfsd4_lockt does a search for a lockstateowner when building the lock
> struct to test. If one is found, it'll set fl_owner to it. Regardless of
> whether that happens, it'll also set fl_lmops. Given that this lock is
> basically a "lightweight" lock that's just used for checking conflicts,
> setting fl_lmops is probably not appropriate for it.
> 
> This behavior exposed a bug in DLM's GETLK implementation where it
> wasn't clearing out the fields in the file_lock before filling in
> conflicting lock info. While we were able to fix this in DLM, it
> still seems pointless and dangerous to set the fl_lmops this way
> when we may have a NULL lockstateowner.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Thanks, applied.--b.

> ---
>  fs/nfsd/nfs4state.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 88db7d3..b6f60f4 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2871,7 +2871,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		file_lock.fl_owner = (fl_owner_t)lockt->lt_stateowner;
>  	file_lock.fl_pid = current->tgid;
>  	file_lock.fl_flags = FL_POSIX;
> -	file_lock.fl_lmops = &nfsd_posix_mng_ops;
>  
>  	file_lock.fl_start = lockt->lt_offset;
>  	file_lock.fl_end = last_byte_offset(lockt->lt_offset, lockt->lt_length);
> -- 
> 1.5.5.6
> 
