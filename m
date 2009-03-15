From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: issues with project quota over nfs
Date: Sun, 15 Mar 2009 16:55:16 -0400
Message-ID: <20090315205516.GB26627@fieldses.org>
References: <AD300F292705ED4089373955E129C1780491E77D@RBSJX.ad.redback.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Brian Wince <bwince-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:41526 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421AbZCOUzS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Mar 2009 16:55:18 -0400
In-Reply-To: <AD300F292705ED4089373955E129C1780491E77D-wMZ1LeS2F8LT6zSRBKwRIVaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 13, 2009 at 09:59:26AM -0700, Brian Wince wrote:
> All,
> We have a Quad-core server running gentoo 2.6.27-r7 that is used as an nfs server for a xfs partition.
> We are using project quota's on directories within this partition and exporting this.
> When a client tries to untar in the dir with project quotas set and reaches the quota limit the load on the NFS server goes up dramatically and stays like this for a few minutes after the tar has gone through trying to write all of it files and failing due to quota limit exceeded.
>  
> Is this a known issue and if so is there anything that can be done to resolve this.
>  
> We do not see this issue if on the locally mounted partition. This only happens over NFS.
>  
> Please let me know if you need more information or if this should be addressed on a different list.

It doesn't sounds familiar to me.  Might also be worth cc:'ing xfs
people.

--b.
