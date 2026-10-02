Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 008053346B4
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 17:24:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790961891; cv=none; b=dAWqhqPfBdK6KWz6eU+qqR6+lf0B6e+Q4bzmu+x32t8soYoxfFrRXXaGTAg0PFQWGWsrsbQ7aAelxG4KCdnD0KdOYAJ/tOO39+ULYWYYXkk5/xkIrWgu6ILyh0Ai8gKhh4OWXgFrscr84RBzB4otW0mX30NCe4Kvtm033HN9xB8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790961891; c=relaxed/simple;
	bh=5nCyMgWLU5LgGpwpMzy0EgNZMlS3fP1mbKQUv6+KT3c=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=rSX2JVdiFU82w+0luAxf7vOJukG8haMFrGIgoL9qhgq1GCXbD89as0ADS7XwG50wZH8OJIXtgGe+Z/FhxZK772FwvFNhbZnTn71c1jlkonBuWcnLC9EoYoMPXQim0Y0M/LUIh7W5J9zvmUk9Uv0kFXy4FZho8fuuDhFgCOnKO7Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kRAA0oU0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kRAA0oU0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3695E1F00893;
	Fri,  2 Oct 2026 17:24:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790961889;
	bh=2czLsZsyukqIQ9W2seyRGNmlfBTaDTjpraI50DxPh5M=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=kRAA0oU0WqcIAUTZp1iQDcW8hIyC+g0L8zO4JSneCZuKErzO1BrY4EuMzBVhrP8aB
	 0yYjbC/VbiyKumHA75kfuSS0SoPN/dn4NZlxOYeWc+XNu2slEUgVP2ChwIOxohNCjw
	 cm7/zSYhrytxgm9rsk3KG8DJKfbI8Dde55Idef/N2MD3YCKnMSJ8EI7iDkf5iUqEz6
	 fKmLH1rp4X72OFfy/qua0IgTVpVPueAxAuvOzeGE/4fQmItFiJCMm9z18oCIyUeal6
	 ZL+8m/TJtbA6SXjwokJ4ZuKOX8SO6V4774NVXlwQecPytSJClzD34AefSw+yDFL/DE
	 Ibt0WQIMZfaBw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5B8E4F40066;
	Fri,  2 Oct 2026 13:24:48 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Fri, 02 Oct 2026 13:24:48 -0400
X-ME-Sender: <xms:4Oi_alM0O9JtUxHqJUunPb0WK_r5luM22nT_TSwOCDEoH12hEXQOAg>
    <xme:4Oi_aiytSsZG27VaL88YqP6Pl16_b48Ku3df9EVKeQTYwN39c66y8_rfm8NxuTMXj
    ZIOXO0hF1l2prm57dod2PUMMEg0TdpyidfXa4iyjAzIRK60WPbMHZht5w>
X-ME-Proxy-Cause: dmFkZTFnNOoPF0/EZGruFf7vUEwtf88wU0qO0RM4bey9j9JG97wsb1LCwVNU4V7JwlQ+aD
    A0YvIylLXl0UuyEDGcQDDgo0DYVR9KLQGYwLay+Kg+1PsfpcJn1kbrNMEhwKR2T6dsrpg4
    PsVw98UHrY3ysmmzQ2BJNs9z3IZIO2IsB/MDivQ0eQ285aAZCoC/xZFqCr+A4smLRRbxJo
    0NU5/x+ax1asULHnvAxDawKzhLb9DCwClB8o2QgiX9gQ2WS526Kuy9l/4/d0TFRfAhwRCC
    y2ONxsDI8x4bSHWEJExzulMLaQiVOwHpEVihjE8MTr9iQzBcBWdbxnLz8dfld9fVNC/CUR
    eTl8ZphXR/MgyxB0aPJNgT1zmA+EMD6n8iJl6vkaSxTw7kwOgpamqMgjBXBKnjpbQzT1bG
    Y87Dllq+TDArnvhkDLjMxCwGw4HNhGyFF47dm+FWVA9irZH2tt4se2fBcHb1dMmGlvh7wB
    6TrLEXgPsoY4uiXSGrW1pXPxLphtONGbdR00QkN8O27VE1LPKOfUwNiNGF/ktygm0nTof7
    yx459Ww2rUL3twPzXIv6Zw/veUZHc+2zFo4SF1+pNkDXwTwOKb4BoU9FiOw0swwSYKmbK6
    +4SJDJvF0hGROzEx7QoBh/kT6PRdrayMLSE9lndWKlD3dRsOrOZB1Cf/KbfA
X-ME-Proxy: <xmx:4Oi_aui8YkGqQ2Iu2cvPG6_x6pkLR0UGLwUPtlrqmXDAmDJtaiq44g>
    <xmx:4Oi_apD8i1fa-5_WbwnLDDavjtjBZQKLtLBAIhJooeIPqIZpFbKvYg>
    <xmx:4Oi_ast3gug-oJGxoblu-Oufu82RNycQKSORKs2E7E8tz8bIsBEPcA>
    <xmx:4Oi_aldhCZECqW0XruDa7BlghdKBqJKpbdC_KWHwLOAFnc9vetHtvw>
    <xmx:4Oi_ap_sad_3kmd9UNRDjan_ka5K5M9YdkaNhKtXqt5Yjs1hrG6hQoRC>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4307BB6006F; Fri,  2 Oct 2026 13:24:48 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AS2CKyXqAVQJ
Date: Fri, 02 Oct 2026 13:24:23 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Chuck Lever" <cel@kernel.org>, NeilBrown <neil@brown.name>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>,
 "Trond Myklebust" <trond.myklebust@hammerspace.com>
Cc: linux-nfs@vger.kernel.org
Message-Id: <2c429fd9-33d5-4045-b478-e1e9e5d68081@app.fastmail.com>
In-Reply-To: <20260924212246.114355-2-cel@kernel.org>
References: <20260924212246.114355-1-cel@kernel.org>
 <20260924212246.114355-2-cel@kernel.org>
Subject: Re: [PATCH v1 1/2] nfs_common: Do not encode an ACL with fewer than three
 entries
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Sep 24, 2026, at 5:22 PM, Chuck Lever wrote:
> nfsacl_encode() reports at least four wire entries for any ACL
> that has entries, because a three-entry ACL is sent as four with a
> synthesized ACL_MASK. The entry encoder then walks a_entries[] up
> to that count.
>
> A one- or two-entry ACL cannot arrive from setfacl, because
> set_posix_acl() validates it first. It can arrive from an NFS
> server. The NFS client caches a GETACL result without validating
> it, and posix_acl_create() hands the cached default ACL to
> nfs3_proc_setacls() when the client creates a directory. The walk
> then reads past the end of the posix_acl allocation and copies the
> bytes into the SETACL arguments.
>
> Report zero wire entries for an ACL with fewer than three, the
> same as for an ACL with none. Count them the same way in
> nfsacl_size(), which otherwise sizes such an ACL at four entries
> and leaves the reserved bytes unwritten in the SETACL arguments.
>
> Fixes: a257cdd0e217 ("[PATCH] NFSD: Add server support for NFSv3 ACLs.")
> Signed-off-by: Chuck Lever <cel@kernel.org>

Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>


> ---
>  fs/nfs_common/nfsacl.c | 3 ++-
>  include/linux/nfsacl.h | 5 +++--
>  2 files changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
> index e2eaac14fd8e..38bb2c294d7c 100644
> --- a/fs/nfs_common/nfsacl.c
> +++ b/fs/nfs_common/nfsacl.c
> @@ -93,7 +93,8 @@ xdr_nfsace_encode(struct xdr_array2_desc *desc, void *elem)
>  int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
>  		  struct posix_acl *acl, int encode_entries, int typeflag)
>  {
> -	int entries = (acl && acl->a_count) ? max_t(int, acl->a_count, 4) : 0;
> +	int entries = (acl && acl->a_count >= 3) ?
> +		      max_t(int, acl->a_count, 4) : 0;
>  	struct nfsacl_encode_desc nfsacl_desc = {
>  		.desc = {
>  			.elem_size = 12,
> diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
> index 8e76a79cdc6a..e4155e69c8dd 100644
> --- a/include/linux/nfsacl.h
> +++ b/include/linux/nfsacl.h
> @@ -26,8 +26,9 @@ static inline unsigned int
>  nfsacl_size(struct posix_acl *acl_access, struct posix_acl *acl_default)
>  {
>  	unsigned int w = 16;
> -	w += max(acl_access ? (int)acl_access->a_count : 3, 4) * 12;
> -	if (acl_default)
> +	if (acl_access && acl_access->a_count >= 3)
> +		w += max((int)acl_access->a_count, 4) * 12;
> +	if (acl_default && acl_default->a_count >= 3)
>  		w += max((int)acl_default->a_count, 4) * 12;
>  	return w;
>  }
> -- 
> 2.55.0
