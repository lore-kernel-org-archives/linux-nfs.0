From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] nfs-utils: detect and log write errors
Date: Sat, 04 Apr 2009 07:52:23 -0400
Message-ID: <49D749F7.10002@RedHat.com>
References: <20090402000430.3234.81110.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39611 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbZDDLzN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Apr 2009 07:55:13 -0400
In-Reply-To: <20090402000430.3234.81110.stgit-Cm81N35Y91hZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Kevin Coffman wrote:
> Address at least one cause of a problem that has been reported
> where it appears that a gss context was successfully created,
> but the server returns GSS_S_NO_CONTEXT.
> 
> ---
> 
> Kevin Coffman (2):
>       svcgssd: check the return code from qword_eol() and log failures
>       cacheio: return any original error from qword_eol
> 
> 
>  support/nfs/cacheio.c     |   10 ++++++++--
>  utils/gssd/svcgssd_proc.c |    4 ++++
>  2 files changed, 12 insertions(+), 2 deletions(-)
Both patches committed...

steved.

