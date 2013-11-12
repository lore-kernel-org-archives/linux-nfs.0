Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41122 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755239Ab3KLXCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 18:02:05 -0500
Date: Tue, 12 Nov 2013 18:02:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Marc Eshel <eshel@us.ibm.com>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
Message-ID: <20131112230201.GB28033@fieldses.org>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
 <20131112194529.GA26341@fieldses.org>
 <OF83A00AE9.3A2F46C6-ON88257C21.007C6003-88257C21.007CE9E4@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF83A00AE9.3A2F46C6-ON88257C21.007C6003-88257C21.007CE9E4@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 12, 2013 at 02:44:21PM -0800, Marc Eshel wrote:
> linux-nfs-owner@vger.kernel.org wrote on 11/12/2013 11:45:29 AM:
> 
> > From: "J. Bruce Fields" <bfields@fieldses.org>
> > To: Anna Schumaker <bjschuma@netapp.com>, 
> > Cc: linux-nfs@vger.kernel.org
> > Date: 11/12/2013 12:07 PM
> > Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
> > Sent by: linux-nfs-owner@vger.kernel.org
> > 
> > On Tue, Nov 12, 2013 at 02:04:05PM -0500, Anna Schumaker wrote:
> > > These patches implement just the SEEK NFS v4.2 operation.  WRITE_PLUS 
> is
> > > still under discussion with the IETF after my last series of patches, 
> so I
> > > am holding off on resubmitting until after spec discussion dies down.
> > > 
> > > Questions?  Comments?  Thoughts?
> > > Anna
> > > 
> > > Anna Schumaker (3):
> > >   NFSD: Update error codes
> > 
> > I don't think I got this first patch.
> > 
> > >   NFSD: Create nfs v4.2 decode ops
> > >   NFSD: Implement SEEK
> > 
> > I'd like to be reassured the protocol is reasonably stable before we
> > commit this.  I haven't been following the ietf wg discussion closely.
> > 
> > And this should initially be disabled by default.  So, probably either:
> 
> It is not enough that it is usable only for client the mount 
> minorversion=2
> anyone using this option knows that they are using a prototype.

The client may default to minorversion=2 some day, so, no, the user
doesn't necessarily know they're using a prototype.

And the server doesn't have any control over what kernel or distro the
client's running.  We want future clients to be able to default to 4.2,
and we don't require servers and clients to be upgraded in lockstep.

--b.
