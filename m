Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50066 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750708AbdAXTtI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jan 2017 14:49:08 -0500
Date: Tue, 24 Jan 2017 14:41:40 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1] nfs: Don't increment lock sequence ID after
 NFS4ERR_MOVED
Message-ID: <20170124194140.GB20844@fieldses.org>
References: <20170122190429.7337.77928.stgit@manet.1015granger.net>
 <69D3212A-874D-42A2-BE65-F3A01B061A87@oracle.com>
 <20170123164913.GB9493@fieldses.org>
 <1F944D3D-A28B-48C5-88CC-39EBD6CB8430@oracle.com>
 <20170124191515.GA20844@fieldses.org>
 <677C0AEE-D64A-489E-B7CE-4BFEEABAA6EA@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <677C0AEE-D64A-489E-B7CE-4BFEEABAA6EA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 24, 2017 at 02:31:37PM -0500, Chuck Lever wrote:
> Adding a justification is OK with me, and please replace the
> list of steps with my updated list above.
> 
> However, your explanation implies that Solaris is the only server
> that might need this fix. Actually _any_ server that supports
> transparent state migration needs clients to get this fix. Lock
> operations on a file that has moved are not able to update the
> sequence ID on the destination server.

Are you sure?  Couldn't an implementation include a server-to-server
protocol that allowed the source and destination server to share stateid
information?

But even if that's possible, it may be unnecessarily complicated, so I
agree I shouldn't be claiming it's a Solaris-specific issue (though it
may be worth documenting that's who first hit this).

--b.

> This backwards-compatible change is OK because:
> 
> - No servers in the wild support migration yet, thus
> NFS4ERR_MOVED is never returned by existing servers
> 
> - Clients that do not support migration should never receive
> NFS4ERR_MOVED on a state-mutating operation
> 
> In other words, this change is necessary only for clients that
> support TSM.
> 
> Salt to taste.
> 
> 
> > --b.
> > 
> >> 
> >> 
> >>> --b.
> >>> 
> >>>>> 
> >>>>> Reported-by: Xuan Qi <xuan.qi@oracle.com>
> >>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >>>>> Cc: stable@vger.kernel.org # v3.7+
> >>>>> ---
> >>>>> include/linux/nfs4.h |    3 ++-
> >>>>> 1 file changed, 2 insertions(+), 1 deletion(-)
> >>>>> 
> >>>>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> >>>>> index bca5363..1b1ca04 100644
> >>>>> --- a/include/linux/nfs4.h
> >>>>> +++ b/include/linux/nfs4.h
> >>>>> @@ -282,7 +282,7 @@ enum nfsstat4 {
> >>>>> 
> >>>>> static inline bool seqid_mutating_err(u32 err)
> >>>>> {
> >>>>> -	/* rfc 3530 section 8.1.5: */
> >>>>> +	/* See RFC 7530, section 9.1.7 */
> >>>>> 	switch (err) {
> >>>>> 	case NFS4ERR_STALE_CLIENTID:
> >>>>> 	case NFS4ERR_STALE_STATEID:
> >>>>> @@ -291,6 +291,7 @@ static inline bool seqid_mutating_err(u32 err)
> >>>>> 	case NFS4ERR_BADXDR:
> >>>>> 	case NFS4ERR_RESOURCE:
> >>>>> 	case NFS4ERR_NOFILEHANDLE:
> >>>>> +	case NFS4ERR_MOVED:
> >>>>> 		return false;
> >>>>> 	};
> >>>>> 	return true;
> >>>>> 
> >>>>> --
> >>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>>>> the body of a message to majordomo@vger.kernel.org
> >>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>> 
> >>>> --
> >>>> Chuck Lever
> >>>> 
> >>>> 
> >>>> 
> >>>> --
> >>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>>> the body of a message to majordomo@vger.kernel.org
> >>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> 
> >> --
> >> Chuck Lever
> >> 
> >> 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
