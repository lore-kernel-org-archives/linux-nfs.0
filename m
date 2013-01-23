Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:38287 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158Ab3AWSfX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 13:35:23 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: David Quigley <selinux@davequigley.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 03/14] LSM: Add flags field to security_sb_set_mnt_opts
 for in kernel mount data.
Date: Wed, 23 Jan 2013 18:35:22 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9183324A2@sacexcmbx05-prd.hq.netapp.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
	 <1358862042-27520-4-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-4-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> There is no way to differentiate if a text mount option is passed from user
> space or the kernel. A flags field is being added to the
> security_sb_set_mnt_opts hook to allow for in kernel security flags to be sent
> to the LSM for processing in addition to the text options received from mount.
> This patch also updated existing code to fix compilation errors.
> 
> Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> ---
>  fs/nfs/super.c           |  3 ++-
>  include/linux/security.h | 13 ++++++++++---
>  security/capability.c    |  5 ++++-
>  security/security.c      |  7 +++++--
>  security/selinux/hooks.c | 12 ++++++++++--
>  5 files changed, 31 insertions(+), 9 deletions(-)
> 
Ditto. Need Acks from James, Stephen and Eric.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
