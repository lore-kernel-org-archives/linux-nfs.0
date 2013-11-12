Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:36857 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757104Ab3KLWo2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 17:44:28 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 12 Nov 2013 15:44:28 -0700
In-Reply-To: <20131112194529.GA26341@fieldses.org>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com> <20131112194529.GA26341@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
From: Marc Eshel <eshel@us.ibm.com>
Message-ID: <OF83A00AE9.3A2F46C6-ON88257C21.007C6003-88257C21.007CE9E4@us.ibm.com>
Date: Tue, 12 Nov 2013 14:44:21 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

linux-nfs-owner@vger.kernel.org wrote on 11/12/2013 11:45:29 AM:

> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: Anna Schumaker <bjschuma@netapp.com>, 
> Cc: linux-nfs@vger.kernel.org
> Date: 11/12/2013 12:07 PM
> Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
> Sent by: linux-nfs-owner@vger.kernel.org
> 
> On Tue, Nov 12, 2013 at 02:04:05PM -0500, Anna Schumaker wrote:
> > These patches implement just the SEEK NFS v4.2 operation.  WRITE_PLUS 
is
> > still under discussion with the IETF after my last series of patches, 
so I
> > am holding off on resubmitting until after spec discussion dies down.
> > 
> > Questions?  Comments?  Thoughts?
> > Anna
> > 
> > Anna Schumaker (3):
> >   NFSD: Update error codes
> 
> I don't think I got this first patch.
> 
> >   NFSD: Create nfs v4.2 decode ops
> >   NFSD: Implement SEEK
> 
> I'd like to be reassured the protocol is reasonably stable before we
> commit this.  I haven't been following the ietf wg discussion closely.
> 
> And this should initially be disabled by default.  So, probably either:

It is not enough that it is usable only for client the mount 
minorversion=2
anyone using this option knows that they are using a prototype.
Marc.
> 
>    - Introduce a new NFSD_V4_SEEK option, or
>    - Combine this and NFSD_V4_SECURITY_LABEL and this into a single
>      NFSD_V4_2 option.
> 
> And recommend "N" for now.
> 
> Probably the latter I guess, to be consistent with the client.  And
> because otherwise we could end up with an awful lot of config options.
> 
> --b.
> 
> > 
> >  fs/nfsd/nfs4proc.c   | 56 +++++++++++++++++++++++++++++++++++++++
> +++++++++++
> >  fs/nfsd/nfs4xdr.c    | 58 +++++++++++++++++++++++++++++++++++++++
> +++++++++++++
> >  fs/nfsd/nfsd.h       |  2 +-
> >  fs/nfsd/xdr4.h       | 16 +++++++++++++++
> >  include/linux/nfs4.h | 23 ++++++++++++++++++---
> >  5 files changed, 151 insertions(+), 4 deletions(-)
> > 
> > -- 
> > 1.8.4.2
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

