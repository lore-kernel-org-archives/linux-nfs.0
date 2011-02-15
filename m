From: <Taousif_Ansari-G5Y5guI6XLZWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH 01/16] NFS remove unnecessary CONFIG_NFS_V4 from
 nfs_read_data
Date: Tue, 15 Feb 2011 14:54:24 +0530
Message-ID: <A1A98FD909DC5248811A65C5D18E9C761D565BB73F@BLRX7MCDC202.AMER.DELL.COM>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
 <1297711116-3139-2-git-send-email-andros@netapp.com>
 <20110215091618.GA29871@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <trond.myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
To: <hch@infradead.org>, <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:48487 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab1BOJZY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 04:25:24 -0500
In-Reply-To: <20110215091618.GA29871@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Christoph Hellwig
Sent: Tuesday, February 15, 2011 2:46 PM
To: andros@netapp.com
Cc: trond.myklebust@netapp.com; linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/16] NFS remove unnecessary CONFIG_NFS_V4 from nfs_read_data

On Mon, Feb 14, 2011 at 02:18:21PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>

Either the patch or the description is incorrect.  If you actually need
it for NFSv2/3 the description should say it.  Otherwise it's just a
"cleanup" which bloats the structure for people not having v4 support
compiled in.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
