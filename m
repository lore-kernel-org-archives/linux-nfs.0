Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14431 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750837Ab3AWSc6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 13:32:58 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: David Quigley <selinux@davequigley.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/14] Security: Add Hook to test if the particular
 xattr is part of a MAC model.
Date: Wed, 23 Jan 2013 18:32:57 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA918332485@sacexcmbx05-prd.hq.netapp.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
	 <1358862042-27520-3-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-3-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> The interface to request security labels from user space is the xattr
> interface. When requesting the security label from an NFS server it is
> important to make sure the requested xattr actually is a MAC label. This allows
> us to make sure that we get the desired semantics from the attribute instead of
> something else such as capabilities or a time based LSM.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> ---
>  include/linux/security.h   | 14 ++++++++++++++
>  security/capability.c      |  6 ++++++
>  security/security.c        |  6 ++++++
>  security/selinux/hooks.c   |  6 ++++++
>  security/smack/smack_lsm.c | 11 +++++++++++
>  5 files changed, 43 insertions(+)
> 
Ditto here. We'll need Acks from James, Stephen, Eric and Casey.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
