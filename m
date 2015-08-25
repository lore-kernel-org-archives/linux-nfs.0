Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46494 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbbHYTR4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2015 15:17:56 -0400
Date: Tue, 25 Aug 2015 15:17:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/2] nfsd: fix unhashing races in nfsv4 stateid
 handling
Message-ID: <20150825191755.GA8579@fieldses.org>
References: <1440434508-16046-1-git-send-email-jeff.layton@primarydata.com>
 <m2vbc47990.fsf@discipline.rit.edu>
 <m2fv3743sb.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2fv3743sb.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2015 at 02:32:52PM -0400, Andrew W Elble wrote:
> >> v2:
> >> - fix the fault injection code to handle the prototype change to
> >>   unhash_lock_stateid
> >
> > Jeff,
> >
> >    We're running with this in place now. It definitely covers the same
> >   bases my quick hack was covering, so I don't foresee any issues with
> >   it - But I'll give a definitive answer tomorrow.
> 
> It's good, no server crashes or memory corruption.

Thanks!--b.
