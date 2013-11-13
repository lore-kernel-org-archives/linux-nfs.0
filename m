Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:48545 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab3KMAdr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 19:33:47 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 12 Nov 2013 17:33:47 -0700
In-Reply-To: <20131112230201.GB28033@fieldses.org>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com> <20131112194529.GA26341@fieldses.org> <OF83A00AE9.3A2F46C6-ON88257C21.007C6003-88257C21.007CE9E4@us.ibm.com> <20131112230201.GB28033@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org, Marc Eshel <eshel@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
From: Marc Eshel <eshel@us.ibm.com>
Message-ID: <OFFBE22971.98BDE120-ON88257C22.0002C427-88257C22.000302F8@us.ibm.com>
Date: Tue, 12 Nov 2013 16:32:51 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> wrote on 11/12/2013 03:02:01 PM:

> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: Marc Eshel/Almaden/IBM@IBMUS, 
> Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
> linux-nfs-owner@vger.kernel.org
> Date: 11/12/2013 03:19 PM
> Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
> 
> On Tue, Nov 12, 2013 at 02:44:21PM -0800, Marc Eshel wrote:
> > linux-nfs-owner@vger.kernel.org wrote on 11/12/2013 11:45:29 AM:
> > 
> > > From: "J. Bruce Fields" <bfields@fieldses.org>
> > > To: Anna Schumaker <bjschuma@netapp.com>, 
> > > Cc: linux-nfs@vger.kernel.org
> > > Date: 11/12/2013 12:07 PM
> > > Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
> > > Sent by: linux-nfs-owner@vger.kernel.org
> > > 
> > > On Tue, Nov 12, 2013 at 02:04:05PM -0500, Anna Schumaker wrote:
> > > > These patches implement just the SEEK NFS v4.2 operation. 
WRITE_PLUS 
> > is
> > > > still under discussion with the IETF after my last series of 
patches, 
> > so I
> > > > am holding off on resubmitting until after spec discussion dies 
down.
> > > > 
> > > > Questions?  Comments?  Thoughts?
> > > > Anna
> > > > 
> > > > Anna Schumaker (3):
> > > >   NFSD: Update error codes
> > > 
> > > I don't think I got this first patch.
> > > 
> > > >   NFSD: Create nfs v4.2 decode ops
> > > >   NFSD: Implement SEEK
> > > 
> > > I'd like to be reassured the protocol is reasonably stable before we
> > > commit this.  I haven't been following the ietf wg discussion 
closely.
> > > 
> > > And this should initially be disabled by default.  So, probably 
either:
> > 
> > It is not enough that it is usable only for client the mount 
> > minorversion=2
> > anyone using this option knows that they are using a prototype.
> 
> The client may default to minorversion=2 some day, so, no, the user
> doesn't necessarily know they're using a prototype.
> 
> And the server doesn't have any control over what kernel or distro the
> client's running.  We want future clients to be able to default to 4.2,
> and we don't require servers and clients to be upgraded in lockstep.

The server accepting 4.2 mount can be under config options but once it is 
mounted it can support the new features by checking for the the version, 
right?
Marc.

> 
> --b.
> 

