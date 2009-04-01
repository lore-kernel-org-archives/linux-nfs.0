From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Wed, 1 Apr 2009 09:10:22 -0400
Message-ID: <20090401131022.GA4002@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229069-8636-1-git-send-email-bhalevy@panasas.com> <20090401043301.GA29339@fieldses.org> <49D32659.8040207@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, steved@redhat.com
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:52172 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763560AbZDANK3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 09:10:29 -0400
In-Reply-To: <49D32659.8040207@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2009 at 11:31:21AM +0300, Benny Halevy wrote:
> On Apr. 01, 2009, 7:33 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Sat, Mar 28, 2009 at 11:31:09AM +0300, Benny Halevy wrote:
> >> Added CONFIG_NFSD_V4_1 and made it depend upon NFSD_V4 and EXPERIMENTAL
> >> Indicate that CONFIG_NFS_V4_1 is for NFS developers at the moment
> > 
> > Stupid question: do we need CONFIG_NFSD_V4_1 at all?  How many people
> > will want to build a kernel with v4.0 but not v4.1?
> 
> That's a good question.  I'd love to get rid of it
> and it seems like like distros, at least RH are going to have it
> configured-in anyway.
> 
> If the main reason to turn 4.1 support off is bugs affecting 4.0
> then I'd much rather fix these bugs rather than hide them.
> 
> > 
> > (And: do we have an interface that allows turning off 4.1 at run-time?
> > That's more important than the config option.)
> 
> No, it's still on our todo list.  We haven't thought this completely
> through, though.  Where would be the best place to implement that?
> Should this be an export option or an nfsd tunable?

Imitating (or extending, if possible) nfsd/versions would be one way.
See fs/nfsd/nfsctl.c:write_versions.  Cc'ing Steved, as I think that was
originally his work.

--b.
