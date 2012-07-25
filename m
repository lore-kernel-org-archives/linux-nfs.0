Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60043 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756300Ab2GYN3a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jul 2012 09:29:30 -0400
Date: Wed, 25 Jul 2012 09:29:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nico Williams <nico@cryptonector.com>
Cc: "Haynes, Tom" <thomas@netapp.com>, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org
Subject: Re: [nfsv4] Constructing a NFSv4 ACL from POSIX mode bits
Message-ID: <20120725132927.GB16617@fieldses.org>
References: <20120724193348.GA4977@netapp.com>
 <CAK3OfOji009CP88tDNOp-nvdPBkvp0oKfJUqhO_TYuZktwhUCg@mail.gmail.com>
 <20120724200932.GM8570@fieldses.org>
 <CAK3OfOiKYJjmDEsOOFqg3wD8pwBir4B4CpOTF1Ab3jdHhJTKwA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAK3OfOiKYJjmDEsOOFqg3wD8pwBir4B4CpOTF1Ab3jdHhJTKwA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2012 at 03:29:07PM -0500, Nico Williams wrote:
> On Tue, Jul 24, 2012 at 3:09 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > But Tom was asking above only about ACE4_WRITE_ACL.  And possibly only
> > in the legacy case.  (Does ZFS have a real ACE4_WRITE_ACL bit?)
> 
> Ah, oops.  That's trickier.  The examples don't say (or I'm not seeing
> it).  IMO the most reasonable thing to do is to make chmod mask away
> the ACE4_WRITE_ACL bits of non-OWNER@/non-owner-user ACEs, but
> subsequent ACL writes can restore ACE4_WRITE_ACL without contributing
> to the w group or world bits of mode.
> 
> That is: to make aclmode=mask most natural and usable a chmod must
> have the expected POSIX behavior of taking away or granting access,
> but never granting anything like ACE4_WRITE_ACL to non-owners, while
> an ACL write should should be able to grant much more access than
> chmod and it should compute a new mode that is as close as possible to
> the new ACL.  This requires storing a mode, an ACL, and one bit to
> indicate whether the ACL was set after the mode or the mode after the
> ACL.

I was with you up to the "one bit to indicate...".  That doesn't sound
necessary to implement the behavior you describe.

--b.
