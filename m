Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50313 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753995AbaIVRxg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 13:53:36 -0400
Date: Mon, 22 Sep 2014 13:53:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/2] NFSD: Add v4.2 SEEK support
Message-ID: <20140922175333.GD16658@fieldses.org>
References: <1409679038-32179-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20140902191043.GD31793@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140902191043.GD31793@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 02, 2014 at 03:10:43PM -0400, J. Bruce Fields wrote:
> On Tue, Sep 02, 2014 at 01:30:36PM -0400, Anna.Schumaker@netapp.com wrote:
> > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > 
> > These patches add server support for the NFS v4.2 operation SEEK.  The first
> > patch adds basic NFS v4.2 infrastructure that all future operations will rely
> > on.  The second patch adds the SEEK operation.
> > 
> > Changes in v2:
> > - Remove CONFIG_NFSD_V4_2_SEEK.
> > - Change the call to preprocess_stateid_op() to only use RD_STATE instead of
> >   RD_STATE | WR_STATE.
> > 
> > These patches and the corresponding client patch are avaliable in the [seek]
> > branch of:
> > 
> > 	git://git.linux-nfs.org/projects/anna/linux-nfs.git
> > 
> > 
> > Questions?  Comments?  Thoughts?
> 
> They look OK to me.  I'll probably merge them once there's evidence
> they're likely to be merged on the client side too.
> 
> Also: has anyone done wireshark support for this yet?

Are you sending a new version of these?

(And ditto for the allocate patches.)

As far as I can tell review comments were mostly nits.

--b.
