Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60411 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab3AWShn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 13:37:43 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: David Quigley <selinux@davequigley.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 05/14] KConfig: Add KConfig entries for Labeled NFS
Date: Wed, 23 Jan 2013 18:37:41 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9183324C0@sacexcmbx05-prd.hq.netapp.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
	 <1358862042-27520-6-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-6-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> This patch adds two entries into the fs/KConfig file. The first entry
> NFS_V4_SECURITY_LABEL enables security label support for the NFSv4 client while
> the second entry NFSD_V4_SECURITY_LABEL enables security labeling support on
> the server side.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> ---
>  fs/nfs/Kconfig  | 16 ++++++++++++++++
>  fs/nfsd/Kconfig | 13 +++++++++++++
>  2 files changed, 29 insertions(+)

Please split this into 2 patches. They should probably be the 2 last
patches in the series.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
