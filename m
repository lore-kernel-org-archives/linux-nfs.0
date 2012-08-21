Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:32482 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943Ab2HUS5O convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Aug 2012 14:57:14 -0400
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120821182420.GC16497@fieldses.org>
Date: Tue, 21 Aug 2012 14:57:03 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Noveck <david.noveck@emc.com>
Message-Id: <286C92E9-17F3-4C7F-B2E6-6BB2F042AA44@oracle.com>
References: <24601061-1606-4A0A-940E-FDAFD1A2A2BB@oracle.com> <39FE3A39-4EB2-4F9F-908F-645C79B30E0F@oracle.com> <20120809211340.GB11538@fieldses.org> <6575B2FD-CCE4-40D5-9CBA-82681EC20E17@oracle.com> <20120809213838.GC11538@fieldses.org> <B28F4673-3650-4BA9-ADDA-F9A8E62A0499@oracle.com> <20120810201348.GB17985@fieldses.org> <12DB2C80-31EB-4317-B1E7-96620A8F7374@oracle.com> <20120810203930.GC17985@fieldses.org> <B38BE4A7-1D82-4B0D-9E71-2C35A1EB30D3@oracle.com> <20120821182420.GC16497@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 21, 2012, at 2:24 PM, J. Bruce Fields wrote:

> On Fri, Aug 10, 2012 at 05:22:17PM -0400, Chuck Lever wrote:
>> Can you explain why you think its a better idea for the client to
>> remove its lease?  For 4.0, it's never had to do that before.  The
>> case you've hit worked before by establishing an additional lease
>> rather than by zapping the old one, for example.
>> 
>> Moreover, it shouldn't matter much that a client doesn't tell a server
>> when it's done, since the client's leases will quickly expire.
>> Generally the client cleans up everything but the lease and clientid4
>> when it unmounts, unless the client crashes, which is hopefully rare
>> (and couldn't result in an "I'm done" notification anyway).  So, I
>> don't see how leaving a lease could be a significant server-side
>> resource issue, or how it might interfere with the operation of other
>> clients.
> 
> Well, I've only seen the problem in this case.  I'm not seeing why the
> client couldn't clean up its clientid as well, but there's also a server
> problem here: I don't believe it should be returning INUSE when the
> preexisting lease actually has no state associated with it any more.  So
> my server's detection of when a clientid has no state is broken.  I'll
> work on that.

Have you tried this optimization with a client that has concurrent mounts with different GSS flavors?  The below patch may make the optimization moot.

> For now I'm also dropping the flavor comparison, if this look OK.

Very interesting, looks plausible.  Commit d5497fc6 is in only 3.5?

With the below change and the current 3.6-rc2 NFS client, does the second open succeed now?

> --b.
> 
> commit d81a6e088c8c884f9be58dfe3647cbff22e1f112
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Aug 21 12:48:30 2012 -0400
> 
>    nfsd4: don't pin clientids to pseudoflavors
> 
>    I added cr_flavor to the data compared in same_creds without any
>    justification, in d5497fc693a446ce9100fcf4117c3f795ddfd0d2 "nfsd4: move
>    rq_flavor into svc_cred".
> 
>    Recent client changes then started making
> 
>    	mount -osec=krb5 server:/export /mnt/
>    	echo "hello" >/mnt/TMP
>    	umount /mnt/
>    	mount -osec=krb5i server:/export /mnt/
>    	echo "hello" >/mnt/TMP
> 
>    to fail due to a clid_inuse on the second open.
> 
>    Mounting sequentially like this with different flavors probably isn't
>    that common outside artificial tests.  Also, the real bug here may be
>    that the server isn't just destroying the former clientid in this case
>    (because it isn't good enough at recognizing when the old state is
>    gone).  But it prompted some discussion and a look back at the spec, and
>    I think the check was probably wrong.  Fix and document.
> 
>    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 6872852..b5058c2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1223,10 +1223,26 @@ static bool groups_equal(struct group_info *g1, struct group_info *g2)
> 	return true;
> }
> 
> +/*
> + * RFC 3530 language requires clid_inuse be returned when the
> + * "principal" associated with a requests differs from that previously
> + * used.  We use uid, gid's, and gss principal string as our best
> + * approximation.  We also don't want to allow non-gss use of a client
> + * established using gss: in theory cr_principal should catch that
> + * change, but in practice cr_principal can be null even in the gss case
> + * since gssd doesn't always pass down a principal string.
> + */
> +static bool is_gss_cred(struct svc_cred *cr)
> +{
> +	/* Is cr_flavor one of the gss "pseudoflavors"?: */
> +	return (cr->cr_flavor > RPC_AUTH_MAXFLAVOR);
> +}
> +
> +
> static bool
> same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
> {
> -	if ((cr1->cr_flavor != cr2->cr_flavor)
> +	if ((is_gss_cred(cr1) != is_gss_cred(cr2))
> 		|| (cr1->cr_uid != cr2->cr_uid)
> 		|| (cr1->cr_gid != cr2->cr_gid)
> 		|| !groups_equal(cr1->cr_group_info, cr2->cr_group_info))

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




