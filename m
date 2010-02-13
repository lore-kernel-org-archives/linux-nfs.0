From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] pnfs: use mds pseudoflavor for ds
Date: Sat, 13 Feb 2010 17:13:01 +0200
Message-ID: <4B76C17D.5040100@panasas.com>
References: <1265999088-3507-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:33847 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754570Ab0BMPNH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Feb 2010 10:13:07 -0500
In-Reply-To: <1265999088-3507-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

committed. thanks!

Benny

On Feb. 12, 2010, 20:24 +0200, andros@netapp.com wrote:
> This patch enables Kerberos connections (or whatever flavor is established
> to the MDS) to the Data Servers.
> 
> Passes connectathon against pNFS/GFS2.
> 
> -->Andy
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
