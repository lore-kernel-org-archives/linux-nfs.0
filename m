Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43584 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754184AbeCHPOG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Mar 2018 10:14:06 -0500
Date: Thu, 8 Mar 2018 10:14:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v7 06/10] NFSD return nfs4_stid in
 nfs4_preprocess_stateid_op
Message-ID: <20180308151406.GB10782@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com>
 <20180220164229.65404-7-kolga@netapp.com>
 <20180307214336.GD28844@fieldses.org>
 <CAN-5tyE9++KkQs064P25NtYkX6L03sNinhVU4Xg41cX_j_EfXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyE9++KkQs064P25NtYkX6L03sNinhVU4Xg41cX_j_EfXg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 07, 2018 at 04:54:50PM -0500, Olga Kornievskaia wrote:
> On Wed, Mar 7, 2018 at 4:43 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Feb 20, 2018 at 11:42:25AM -0500, Olga Kornievskaia wrote:
> >> @@ -5143,8 +5144,11 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
> >>       if (!status && filpp)
> >>               status = nfs4_check_file(rqstp, fhp, s, filpp, tmp_file, flags);
> >>  out:
> >> -     if (s)
> >> +     if (s) {
> >> +             if (!status && cstid)
> >> +                     *cstid = s;
> >>               nfs4_put_stid(s);
> >
> > Are you sure that's right?  Normally you wouldn't drop a reference on
> > something you're returning.
> 
> Hm. Should it be taken here then? I do up the reference on the stateid
> later in the code in the nfds4_copy().

Yeah, you probably want

		if (!status && cstid)
			*cstid = s;
		else
			nfs4_put_stid(s);

instead of doing the increment later in nfsd4_copy() code.

Otherwise, in theory a close or free_stateid or something could
race in and destroy the stateid before you get the chance to increment
the reference again.

--b.
