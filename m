Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42408 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965393AbcIVRfP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 13:35:15 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2DE263F1F0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 17:35:15 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] mountstats: add pNFS READs and WRITEs
To: Scott Mayhew <smayhew@redhat.com>
References: <1474565531-3401-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <52ab85e7-6ad5-878b-c41d-b13409659e56@RedHat.com>
Date: Thu, 22 Sep 2016 13:35:14 -0400
MIME-Version: 1.0
In-Reply-To: <1474565531-3401-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/22/2016 01:32 PM, Scott Mayhew wrote:
> These counters are already in /proc/self/mountstats but the mountstats
> program doesn't display them.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed.... Thanks!

steved.
> ---
>  tools/mountstats/mountstats.py | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 4ca4bc4..88ccdae 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -412,6 +412,8 @@ class DeviceData:
>          print('  short reads: %d  short writes: %d' % \
>              (self.__nfs_data['shortreads'], self.__nfs_data['shortwrites']))
>          print('  NFSERR_DELAYs from server: %d' % self.__nfs_data['delay'])
> +        print('  pNFS READs: %d' % self.__nfs_data['pnfsreads'])
> +        print('  pNFS WRITEs: %d' % self.__nfs_data['pnfswrites'])
>  
>      def display_nfs_bytes(self):
>          """Pretty-print the NFS event counters
> 
