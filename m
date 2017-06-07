Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36740 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751563AbdFGQCk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Jun 2017 12:02:40 -0400
Date: Wed, 7 Jun 2017 12:02:35 -0400
To: NeilBrown <neilb@suse.com>
Cc: Justin Mitchell <jumitche@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH 3/3] nfs.conf tidy ups
Message-ID: <20170607160235.GC26995@fieldses.org>
References: <1495468363.4169.13.camel@redhat.com>
 <87shjcbige.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87shjcbige.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 07, 2017 at 01:11:13PM +1000, NeilBrown wrote:
> On Mon, May 22 2017, Justin Mitchell wrote:
> 
> > Remove the line length parameter and associated code which
> > led to buffer overruns in the line parsing code.
> > Also drops the undocumented 'include' directive.
> 
> No, please don't drop the "include" directive.
> It was there for a reason.  See commit  be38fd8b8011c6bd.
> 
> Yes, it should be documented.  I'm happy to provide documentation.  But
> please do [not] remove things without first understanding why they are there.

Looks like that commit did add documentation to nfs.conf.man.

Note also we try to give extra scrutiny to user visible changes like
this which might break existing user setups, so they should really come
in their own patch that mentions the change in the subject line.

--b.
