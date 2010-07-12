From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 0/2] pnfs-submit Re-initialize pnfs_layout_type when segs
 list is empty
Date: Mon, 12 Jul 2010 18:48:47 +0300
Message-ID: <4C3B395F.8080903@panasas.com>
References: <1278693571-3328-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:11172 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756079Ab0GLPst (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 11:48:49 -0400
In-Reply-To: <1278693571-3328-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/09/2010 07:39 PM, andros@netapp.com wrote:
> e keep the nfs_inode->layout when the segs list is empty, and we remove it
> from the nfs_client cl_layouts list, but we fail to reset the other fields.
> Re-initialize the layout (all except for the refcount) so that the next
> layoutget with potentially new deviceid.... sets the layout fields.
> 
> Note: API change to layoutdriver_io_operations free_layout
> 
> 0001-SQUASHME-pnfs-submit-reinitialize-pnfs_layout_type.patch
> 0002-SQUASHME-pnfs-submit-file-layout-free_layout-init_on.patch
> 
> Tested
> 
> CONFIG_V4_I set:
> Connectathon tests pass against GFS2/pNFS and pyNFS file layout servers. Both
> return-on-close and not return-on-close tested.
> 
> CONFIG_V4_I not set:
> NFSv4.0 mount passes Connectathon tests.
> 
> -->Andy
> 

Andy sorry to get on your case. But I hate it. It is an hack that takes
us back not forward. (Code less clean more obscure)

For starts don't save me a vector please. The two functions are unrelated
see your last patch 0002 there is no common code and a return in the middle
of an if() which should trigger an alarm for a bad API.

Second if at all, then the costume is to initialize on re-use not on end
of previous operation. (Clearer intentions, might not be reused, etc...)

3rd, if you'd follow my original proposal you'll see that this hack is not
needed.

If these patches fix an actual bug you've been hitting, could you just fix
the particular field in question that needs zeroing. And we can see how to
solve it better.

Thanks
Boaz
