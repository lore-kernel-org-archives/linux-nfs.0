Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53434 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019Ab1JTMCI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 08:02:08 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RGrK3-0001uo-TZ
	for linux-nfs@vger.kernel.org; Thu, 20 Oct 2011 08:02:07 -0400
Date: Thu, 20 Oct 2011 08:02:07 -0400
To: linux-nfs@vger.kernel.org
Subject: Re: Does NFS4 need st_gen?
Message-ID: <20111020120207.GL5444@fieldses.org>
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
 <20111019171551.GA32028@fieldses.org>
 <87d3dsdcf4.fsf@inspiron.ap.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87d3dsdcf4.fsf@inspiron.ap.columbia.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2011 at 03:11:27PM -0400, Nikolaus Rath wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> > On Wed, Oct 19, 2011 at 10:17:43AM -0400, Nikolaus Rath wrote:
> >> Does NFS4 still depend on inode generation numbers? I understand that
> >> earlier NFS versions used file handles based on inode and generation
> >> number, but it seems to me that this shouldn't be required anymore with
> >> the (stateful) NFS4.
> >
> > Yes, it's true that NFSv4 has open and close operations, but filehandles
> > are still used a great deal outside of that, and clients are still
> > allowed to assume that the same filehandle always refers to the same
> > object.
> >
> > http://www.ietf.org/rfc/rfc3530.txt, section 4.2.1:
> >
> > 	"If two filehandles from the same server are equal, they MUST
> > 	refer to the same file."
> 
> Duh - that's a disappointment. Thanks for the pointer!

Just curious--why do you care?

--b.
