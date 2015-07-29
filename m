Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:32981 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337AbbG2Thf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jul 2015 15:37:35 -0400
Date: Wed, 29 Jul 2015 15:37:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        tigran.mkrtchyan@desy.de
Subject: Re: [PATCH 3/4] 4.1 xdrdef: Fix bad define of sec_label4
Message-ID: <20150729193734.GB21949@fieldses.org>
References: <55B76B9B.4090700@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55B76B9B.4090700@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 28, 2015 at 07:46:35PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---

See nfs4.1/xdrdef/README and please update that README and nfs4.x.diff
too if necessary (and report to nfsv4@ietf.org if this is still a bug in
the minorversion 2 draft).

--b.

>  nfs4.1/xdrdef/nfs4.x | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/nfs4.1/xdrdef/nfs4.x b/nfs4.1/xdrdef/nfs4.x
> index 024e0b4..cb3db7e 100644
> --- a/nfs4.1/xdrdef/nfs4.x
> +++ b/nfs4.1/xdrdef/nfs4.x
> @@ -852,7 +852,7 @@ typedef change_policy4  fattr4_change_policy;
>  typedef uint64_t        fattr_space_freed;
>  typedef change_attr_type4
>                  fattr4_change_attr_type;
> -typedef sec_label4      fattr_sec_label<>;
> +typedef sec_label4      fattr4_sec_label;
>  
>  %/*
>  % * REQUIRED Attributes
> -- 
> 2.4.3
