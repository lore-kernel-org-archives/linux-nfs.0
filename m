Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51776 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753181AbeDKM6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Apr 2018 08:58:03 -0400
Date: Wed, 11 Apr 2018 14:59:03 +0200
From: Thorsten Kukuk <kukuk@suse.de>
To: Steve Dickson <SteveD@RedHat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Subject: Re: [Libtirpc-devel] [PATCH 1/2] Restore using reserve ports for
 client connections
Message-ID: <20180411125903.GA28242@suse.de>
References: <20180410213043.5545-1-steved@redhat.com>
 <1E130010-3BB3-4BB8-9521-1B6096BC615B@oracle.com>
 <44316a1b-82ff-261c-b691-31b5621fb4e7@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <44316a1b-82ff-261c-b691-31b5621fb4e7@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 11, Steve Dickson wrote:

> 
> Hey,
> 
> On 04/10/2018 06:17 PM, Chuck Lever wrote:
> > 
> > 
> >> On Apr 10, 2018, at 3:30 PM, Steve Dickson <steved@redhat.com> wrote:
> >>
> >> Commit 46e04a73 changed both clnt_com_create()
> >> and clnt_tli_create() to avoid using reserve ports when
> >> creating connection to the server.
> >>
> >> For certain legacy apps, the client has to used
> >> reserve port to be able to communicate with its
> >> server so using of reserve ports is restored.
> > 
> > Hi Steve-
> > 
> > Which legacy apps use clnt_tli_create and require this behavior?
> yphelper, yppush and ypxfr via the clnt_create() call. At least
> that's all I have found so far.

Yes, and I need to change that like Solaris is doing it, only a
question of time on my side :(

  Thorsten

-- 
Thorsten Kukuk, Distinguished Engineer, Senior Architect SLES & CaaSP
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendoerffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nuernberg)
