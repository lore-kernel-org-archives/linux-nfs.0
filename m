Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751145AbdIMP6f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 11:58:35 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5F1FB3C29
        for <linux-nfs@vger.kernel.org>; Wed, 13 Sep 2017 15:58:35 +0000 (UTC)
Message-ID: <1505318305.15819.33.camel@redhat.com>
Subject: Re: [PATCH 5/7] nfs-utils: Import libnfsidmap codebase
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@redhat.com>
Date: Wed, 13 Sep 2017 16:58:25 +0100
In-Reply-To: <0c78c3e5-0ec8-1dcf-e608-77693596097d@RedHat.com>
References: <1505311126.15819.20.camel@redhat.com>
         <1505311491.15819.27.camel@redhat.com>
         <0c78c3e5-0ec8-1dcf-e608-77693596097d@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-09-13 at 10:35 -0400, Steve Dickson wrote:
> 
> On 09/13/2017 10:04 AM, Justin Mitchell wrote:
> > Merge the libnfsidmap code tree into nfs-utils.
> > These are the original unmodified files, cherry picked only the
> > necessary files that dont duplicate code, so will not build
> > correctly at this stage.
> > 
> > Signed-off-by: Justin Mitchell <jumitche@redhat.com>
> > ---
> >  utils/libnfsidmap/AUTHORS             |    1 +
> >  utils/libnfsidmap/COPYING             |   30 +
> >  utils/libnfsidmap/Makefile.am         |   62 ++
> >  utils/libnfsidmap/README              |  126 ++++
> >  utils/libnfsidmap/gums.c              |  788 ++++++++++++++++++++
> >  utils/libnfsidmap/idmapd.conf         |  137 ++++
> >  utils/libnfsidmap/idmapd.conf.5       |  308 ++++++++
> >  utils/libnfsidmap/libnfsidmap.c       |  709 ++++++++++++++++++
> >  utils/libnfsidmap/libnfsidmap.pc.in   |   11 +
> >  utils/libnfsidmap/libtest.c           |  160 ++++
> >  utils/libnfsidmap/nfs4_uid_to_name.3  |  174 +++++
> >  utils/libnfsidmap/nfsidmap.h          |   67 ++
> >  utils/libnfsidmap/nfsidmap_internal.h |   72 ++
> >  utils/libnfsidmap/nss.c               |  468 ++++++++++++
> >  utils/libnfsidmap/static.c            |  412 +++++++++++
> >  utils/libnfsidmap/umich_ldap.c        | 1302 +++++++++++++++++++++++++++++++++
> Quickly looking at this... I think the code should
> go under support/nfsidmap since that's where the
> other libraries live... Not sure how difficult it
> will be to change that... 
> 
> steved.

Okay, thats no problem, will wait and see what other comments there are
before i post the corrected version.

Justin



