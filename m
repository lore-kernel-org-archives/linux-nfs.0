Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37928 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751111AbdJCIPJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Oct 2017 04:15:09 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9EECE81E19
        for <linux-nfs@vger.kernel.org>; Tue,  3 Oct 2017 08:15:09 +0000 (UTC)
Message-ID: <1507018507.3567.8.camel@redhat.com>
Subject: Re: [PATCH 0/7] nfs-utils: Merge libnfsidmap tree with nfs-utils
 UPDATED
From: Justin Mitchell <jumitche@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Steve Dickson <SteveD@RedHat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date: Tue, 03 Oct 2017 09:15:07 +0100
In-Reply-To: <20171002163852.GC16092@parsley.fieldses.org>
References: <1505397745.3665.4.camel@redhat.com>
         <300b358d-689a-1e6b-c91d-c8e46c740ab1@RedHat.com>
         <20171002163852.GC16092@parsley.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-10-02 at 12:38 -0400, J. Bruce Fields wrote:
> On Mon, Oct 02, 2017 at 10:03:06AM -0400, Steve Dickson wrote:
> > 
> > 
> > On 09/14/2017 10:02 AM, Justin Mitchell wrote:
> > > It was suggested that merging the trees is more desirable than splitting
> > > the common code out into a shared library, so this patch set attempts to
> > > merge the libnfsidmap code into nfs-utils.
> > > 
> > > The main body of the code, copyright notices, and readme are copied
> > > across, omitting the shared conffile code, and trimming unused files
> > > like strlcpy.c and queue.h. The build files of both are adjusted to the
> > > new structure, and the dependent nfs-utils now link to the included
> > > shared library instead of an external one.
> > > 
> > > The source libnfsidmap tree did include some packaging files for
> > > debian/dkpg which have been omitted, there are no packaging materials in
> > > nfs-utils to merge them with, and i welcome advice on what should be
> > > done here.
> > > 
> > > Change: libnfsidmap imported as support/nfsidmap/ 
> > A quick status on this... I'm working on this but this patch is going
> > to cause a packaging nightmare... since the libnfsidmap package is 
> > required by nfs-utils which now is installing that lib... so
> > this might take some time... 
> 
> Would it help to start by keeping the separate libnfsidmap rpm, but just
> building it from nfs-utils instead of from separate source?

The BuildRequires for libnfsidmap is no longer necessary, as when you
configure and build nfs-utils from the top it will automatically build
and link to the merged libnfsidmap code.

I would expect then to list libnfsidmap as a sub-package within the
nfs-utils spec file so that the end result is the same set of rpms out
as we had before the merge.

Neither source tree contained any rpm packaging materials otherwise I
would have adjusted and tested it as part of the patch set.

