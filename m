Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52389 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726911AbeHTQPi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Aug 2018 12:15:38 -0400
Received: from smtp.corp.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.25])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8376E81F0F
        for <linux-nfs@vger.kernel.org>; Mon, 20 Aug 2018 13:00:05 +0000 (UTC)
Subject: Re: [nfs-utils PATCH 0/2] A few fixes to rpc.nfsd enabling/disabling
 minor version 0
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20180810204421.21882-1-smayhew@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <a8b4479e-3a93-cc52-4099-5f0548813a02@RedHat.com>
Date: Mon, 20 Aug 2018 09:00:04 -0400
MIME-Version: 1.0
In-Reply-To: <20180810204421.21882-1-smayhew@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/10/2018 04:44 PM, Scott Mayhew wrote:
> The first patch allows version 4.0 to be enabled/disabled via the
> nfs.conf file.
> 
> The second patch adds a variable to track when the user explicitly
> requested version 4.0 to be enabled/disabled so that '+4.0' or '-4.0'
> can be written to /proc/fs/nfsd/versions on 4.11 (first appearance of
> commit d3635ff07e8c "nfsd: fix configuration of supported minor
> versions").
> 
> Note that if version 4.0 is disabled (either via '-N4.0' on the command
> line or via 'vers4.0=n' in nfs.conf), then it must be re-enabled
> explicitly (either via '-V4.0' on the command line or via 'vers4.0=y' in
> nfs.conf).  Simply removing the '-N4.0'/'vers4.0=n' options and/or
> replacing them with '-V4/vers4=y' is not sufficient.  It is my
> understanding that that is the desired behavior.
> 
> Scott Mayhew (2):
>   nfsd: allow verson 4.0 to be enabled/disabled via nfs.conf
>   nfsd: track when the user explicitly requested version 4.0
> 
>  utils/nfsd/nfsd.c   | 17 +++++++++++------
>  utils/nfsd/nfssvc.c | 14 +++++++++-----
>  utils/nfsd/nfssvc.h |  3 ++-
>  3 files changed, 22 insertions(+), 12 deletions(-)
> 
Committed both patch... Nice work!! Thank you!!!

steved.
