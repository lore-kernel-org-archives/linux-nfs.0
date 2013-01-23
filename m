Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60237 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852Ab3AWSgd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 13:36:33 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: David Quigley <selinux@davequigley.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 04/14] SELinux: Add new labeling type native labels
Date: Wed, 23 Jan 2013 18:36:30 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9183324B1@sacexcmbx05-prd.hq.netapp.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
	 <1358862042-27520-5-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-5-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> There currently doesn't exist a labeling type that is adequate for use with
> labeled NFS. Since NFS doesn't really support xattrs we can't use the use xattr
> labeling behavior. For this we developed a new labeling type. The native
> labeling type is used solely by NFS to ensure NFS inodes are labeled at runtime
> by the NFS code instead of relying on the SELinux security server on the client
> end.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> ---
>  include/linux/security.h            |  3 +++
>  security/selinux/hooks.c            | 35 ++++++++++++++++++++++++++---------
>  security/selinux/include/security.h |  2 ++
>  security/selinux/ss/policydb.c      |  5 ++++-
>  4 files changed, 35 insertions(+), 10 deletions(-)

...OK. You get the drift... :-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
