Return-Path: <aweits@rit.edu>
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: bcodding redhat <bcodding@redhat.com>,
  "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
  "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 00/11] Fix OPEN/CLOSE races
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
	<m2vainowk1.fsf@discipline.rit.edu>
	<1510008607.3861.1.camel@primarydata.com>
Date: Mon, 06 Nov 2017 18:13:40 -0500
In-Reply-To: <1510008607.3861.1.camel@primarydata.com> (Trond Myklebust's
	message of "Mon, 6 Nov 2017 22:50:09 +0000")
Message-ID: <m2po8vova3.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trondmy@primarydata.com> writes:

>> Seeing a lot of TEST_STATEID's for the invalid stateid go over the
>> wire - this also makes the server hit this quite a bit:
>> 
>> pr_warn_ratelimited("NFSD: client %s testing state ID "
>>                         "with incorrect client ID\n", addr_str);
>> 
>
> I'm not seeing that at all. Can you please elaborate on which server
> errors are triggering this? I'd not expect to ever see TEST_STATEID on
> a normal run.

BTW, this is mounting localhost on a test laptop, running blogbench in the
mounted directory "blogbench -d ."

https://www.pureftpd.org/project/blogbench

Working to gather more information clientside.

patch-explanation (at least for the server messages)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0d98d73bd84e..e3c57f5af85e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -73,6 +73,7 @@
 #define ZERO_STATEID(stateid) (!memcmp((stateid), &zero_stateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &one_stateid, sizeof(stateid_t)))
 #define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
+#define CLOSE_STATEID(stateid)  (!memcmp((stateid), &close_stateid, sizeof(stateid_t)))
 
 /* forward declarations */
 static bool check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner);
@@ -4880,7 +4881,7 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	struct nfs4_stid *s;
 	__be32 status = nfserr_bad_stateid;
 
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid) || CLOSE_STATEID(stateid))
 		return status;
 	/* Client debugging aid. */
 	if (!same_clid(&stateid->si_opaque.so_clid, &cl->cl_clientid)) {
@@ -4938,7 +4939,7 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	else if (typemask & NFS4_DELEG_STID)
 		typemask |= NFS4_REVOKED_DELEG_STID;
 
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid) || CLOSE_STATEID(stateid))
 		return nfserr_bad_stateid;
 	status = lookup_clientid(&stateid->si_opaque.so_clid, cstate, nn);
 	if (status == nfserr_stale_clientid) {



-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
