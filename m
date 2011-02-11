Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44219 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756989Ab1BKUUL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 15:20:11 -0500
Subject: Re: [PATCH 0/7] pnfs wave 4 proposal
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
Date: Fri, 11 Feb 2011 15:19:54 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <76B48A68-FCC3-4E52-9FF3-43C6C68CD0AA@netapp.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I don't see pnfs_initiate_write

-->Andy

On Feb 11, 2011, at 11:54 AM, Fred Isaman wrote:

> These apply on top of Andy's wave3-on-nfs-for-next-rev4.
> 
> These patches give write functionality to the pnfs file layout driver.
> The primary limitation is that we have not yet modified the commit
> code, so we can not yet handle COMMITs to the data server.  We get
> around this for the moment by sending any WRITE to a data server which
> does not have commit-to-mds set as a SYNCH write.
> 
> Fred
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

