Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43106 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624AbbLLMP5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Dec 2015 07:15:57 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 31611C0B9307
	for <linux-nfs@vger.kernel.org>; Sat, 12 Dec 2015 12:15:57 +0000 (UTC)
Subject: Re: [nfs-utils PATCH v2 2/2] mountstats: add missing v4.2 operations
To: Scott Mayhew <smayhew@redhat.com>
References: <1449767223-52696-1-git-send-email-smayhew@redhat.com>
 <1449767223-52696-2-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <566C0FFC.7060203@RedHat.com>
Date: Sat, 12 Dec 2015 07:15:56 -0500
MIME-Version: 1.0
In-Reply-To: <1449767223-52696-2-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/10/2015 12:07 PM, Scott Mayhew wrote:
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed...

steved.
> ---
>  tools/mountstats/mountstats.py | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 1e2811f..4ca4bc4 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -150,6 +150,8 @@ Nfsv3ops = [
>      'COMMIT'
>  ]
>  
> +# This list should be kept in-sync with the NFSPROC4_CLNT_* enum in
> +# include/linux/nfs4.h in the kernel.
>  Nfsv4ops = [
>      'NULL',
>      'READ',
> @@ -204,7 +206,12 @@ Nfsv4ops = [
>      'FREE_STATEID',
>      'GETDEVICELIST',
>      'BIND_CONN_TO_SESSION',
> -    'DESTROY_CLIENTID'
> +    'DESTROY_CLIENTID',
> +    'SEEK',
> +    'ALLOCATE',
> +    'DEALLOCATE',
> +    'LAYOUTSTATS',
> +    'CLONE'
>  ]
>  
>  class DeviceData:
> 
