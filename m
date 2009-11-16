From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [round2 PATCH 0/7] nfs-utils: add support for authenticated callbacks
Date: Mon, 16 Nov 2009 12:29:58 -0500
Message-ID: <4B018C16.8030409@RedHat.com>
References: <20090520151651.2986.29621.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbZKPR3z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 12:29:55 -0500
In-Reply-To: <20090520151651.2986.29621.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/20/2009 11:20 AM, Kevin Coffman wrote:
> Hi Steve,
> 
> This series adds support to gssd and svcgssd to support
> authenticated callbacks.
> 
> 1) adds the name the client used when authenticating to the
> svcgssd downcall information.  This is used by nfsd to determine
> the target name when initiating the callback.
> 
> 2) splits out the processing of update_client_list() to accomodate
> a new upcall pipe added in the next patch.
> 
> 3) changes gssd to process all rpc_pipefs directories (this patch is
> changed from the first round to process all directories rather than
> special-casing directories)
> 
> 4) a debugging aid to distinquish which upcall is being processed
> 
> 6) adds support for handling the "target=" attribute in the new upcall
> 
> 7) adds support for handling the "service=" attribute in the new upcall
> 
> NOTE:  For authenticated callbacks to work, an NFS client or an
> NFS server must be running both rpcgssd _and_ rpcsvcgssd.
> This will require a configuration change.
> 
> A future patch is planned to combine gssd and svcgssd into
> a single daemon to make configuration easier.  However, there
> are some architectural issues that must be resolved first.
> 
> ---
> 
> Kevin Coffman (1):
>       gssd: add upcall support for callback authentication
> 
> Olga Kornievskaia (6):
>       gssd: process service= attribute in new upcall
>       gssd: process target= attribute in new upcall
>       gssd: handle new client upcall
>       gssd: print full client directory being handled
>       gssd: refactor update_client_list()
>       svcgssd: add client's principal name to downcall information
> 
> 
>  utils/gssd/gssd.c           |    6 -
>  utils/gssd/gssd.h           |   12 +
>  utils/gssd/gssd_main_loop.c |  102 +++++++++++-
>  utils/gssd/gssd_proc.c      |  365 +++++++++++++++++++++++++++++++++++--------
>  utils/gssd/krb5_util.c      |   21 ++
>  utils/gssd/krb5_util.h      |    3 
>  utils/gssd/svcgssd_proc.c   |   94 ++++++++++-
>  7 files changed, 505 insertions(+), 98 deletions(-)
> 
Sorry for taking so long to get to this... I did some quick regression
testing and did not see any problems... but it not clear I actually 
tested this new functionality....

I'm going to go ahead and commit this, but if you could supply me 
with some tests that explicitly test this new functionality would
be appreciated... 

steved.
  
