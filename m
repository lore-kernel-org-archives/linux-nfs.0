Return-Path: <aweits@rit.edu>
From: Andrew W Elble <aweits@rit.edu>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd4: Prevent the reuse of a closed stateid
References: <2087b4cab6c695a7df01c1135f1773c9b762f0b0.1508248427.git.bcodding@redhat.com>
	<1508258356.4747.6.camel@redhat.com>
	<F5CCE778-0A1E-4818-8D9B-7F45FC3E7F4B@redhat.com>
	<1508264368.4747.17.camel@redhat.com>
	<D68224FD-D466-4DF1-9CBF-EAF03976B9AF@redhat.com>
Date: Wed, 18 Oct 2017 20:48:36 -0400
In-Reply-To: <D68224FD-D466-4DF1-9CBF-EAF03976B9AF@redhat.com> (Benjamin
	Coddington's message of "Tue, 17 Oct 2017 16:40:05 -0400")
Message-ID: <m2o9p4vu6z.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
List-ID: <linux-nfs.vger.kernel.org>


Benjamin Coddington <bcodding@redhat.com> writes:

> On 17 Oct 2017, at 14:19, Jeff Layton wrote:
>
>> Also we now have to take the st_mutex in nfsd4_find_existing_open, just to
>> check sc_type.  Neither of those are probably unreasonable, it's just
>> messier than I'd like.
>
> It is indeed messy.. no argument.  I'll spin up your suggestion to unhash
> the stateid before updating and take it for a ride and let you know the
> results.  Thanks for looking at this.

I threw this against a quick lockdep run and didn't see anything that
surprised me. I think we developed a harmless warning in
nfsd4_process_open2() a ways back?

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 94ef63a10146..87535f2688be 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -64,6 +64,9 @@
 static const stateid_t currentstateid = {
 	.si_generation = 1,
 };
+static const stateid_t invalidstateid = {
+        .si_generation = U32_MAX,
+};
 
 static u64 current_sessionid = 1;
 
@@ -5362,11 +5365,11 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
-	nfs4_inc_and_copy_stateid(&close->cl_stateid, &stp->st_stid);
-	mutex_unlock(&stp->st_mutex);
+	memcpy(&close->cl_stateid, &invalidstateid, sizeof(stateid_t));
 
 	nfsd4_close_open_stateid(stp);
 
+	mutex_unlock(&stp->st_mutex);
 	/* put reference from nfs4_preprocess_seqid_op */
 	nfs4_put_stid(&stp->st_stid);
 out:
-- 
1.8.3.1

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
