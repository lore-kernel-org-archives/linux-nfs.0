From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 2/5] nfsd41: bound forechannel drc size by memory
 usage
Date: Sun, 30 Aug 2009 09:38:33 +0300
Message-ID: <4A9A1E69.6020304@panasas.com>
References: <1251389264-3009-1-git-send-email-andros@netapp.com>	<1251389264-3009-2-git-send-email-andros@netapp.com>	<1251389264-3009-3-git-send-email-andros@netapp.com> <20090828204115.GB2462@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: andros@netapp.com, linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:61673
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751841AbZH3Gif (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2009 02:38:35 -0400
In-Reply-To: <20090828204115.GB2462@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 28, 2009, 23:41 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> Remind me why serverfault and not resource here?
> 
> --b.
> 

NFS4ERR_RESOURCE is not a valid nfsv4.1 error.

Benny
