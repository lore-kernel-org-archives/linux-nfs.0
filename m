Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:33365 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010Ab3AWSbb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 13:31:31 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: David Quigley <selinux@davequigley.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 01/14] Security: Add hook to calculate context based on
 a negative dentry.
Date: Wed, 23 Jan 2013 18:31:29 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91833244F@sacexcmbx05-prd.hq.netapp.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
	 <1358862042-27520-2-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> There is a time where we need to calculate a context without the
> inode having been created yet. To do this we take the negative dentry and
> calculate a context based on the process and the parent directory contexts.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> ---
>  include/linux/security.h | 27 +++++++++++++++++++++++++++
>  security/capability.c    |  8 ++++++++
>  security/security.c      | 10 ++++++++++
>  security/selinux/hooks.c | 35 +++++++++++++++++++++++++++++++++++
>  4 files changed, 80 insertions(+)

Linus won't accept a patch that changes the security code from Bruce or
myself without acks from the security maintainers. I assume that means
we need to get at least an ack from James Morris, and then possibly
Stephen and Eric too...


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
