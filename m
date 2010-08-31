Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37501 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932461Ab0HaPwf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 11:52:35 -0400
Message-ID: <4C7D2540.1070706@panasas.com>
Date: Tue, 31 Aug 2010 18:52:32 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: andros@netapp.com
CC: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 48/50] SQUASHME pnfs_post_submit: layout type enum
References: <1281735122-1496-1-git-send-email-andros@netapp.com> <1281735122-1496-33-git-send-email-andros@netapp.com> <1281735122-1496-34-git-send-email-andros@netapp.com> <1281735122-1496-35-git-send-email-andros@netapp.com> <1281735122-1496-36-git-send-email-andros@netapp.com> <1281735122-1496-37-git-send-email-andros@netapp.com> <1281735122-1496-38-git-send-email-andros@netapp.com> <1281735122-1496-39-git-send-email-andros@netapp.com> <1281735122-1496-40-git-send-email-andros@netapp.com> <1281735122-1496-41-git-send-email-andros@netapp.com> <1281735122-1496-42-git-send-email-andros@netapp.com> <1281735122-1496-43-git-send-email-andros@netapp.com> <1281735122-1496-44-git-send-email-andros@netapp.com> <1281735122-1496-45-git-send-email-andros@netapp.com> <1281735122-1496-46-git-send-email-andros@netapp.com> <1281735122-1496-47-git-send-email-andros@netapp.com> <1281735122-1496-48-git-send-email-andros@netapp.com> <1281735122-1496-49-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-49-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/14/2010 12:32 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  include/linux/nfs4.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 6ee7357..2d3d277 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -579,6 +579,8 @@ enum state_protect_how4 {
>  
>  enum pnfs_layouttype {
>  	LAYOUT_NFSV4_1_FILES  = 1,
> +	LAYOUT_OSD2_OBJECTS = 2,
> +	LAYOUT_BLOCK_VOLUME = 3,
>  };
>  

Rrr, what's the point? it's just an enum.
All STD derived types and constants should just be kept intact. 
Implemented or not is irrelevant.

which calls for a rename BTW.
pnfs_layouttype => nfs4_layouttype (The name nfs4.h should be an
hint I'd say)

>  /* used for both layout return and recall */

