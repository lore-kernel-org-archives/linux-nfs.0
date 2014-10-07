Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60033 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462AbaJGNqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2014 09:46:16 -0400
Date: Tue, 7 Oct 2014 09:46:13 -0400
To: Srikrishan Malik <srimalik@in.ibm.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fail the test if number of supported attrs are more than
 expected.
Message-ID: <20141007134613.GB23258@fieldses.org>
References: <1407994346-18244-1-git-send-email-srimalik@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1407994346-18244-1-git-send-email-srimalik@in.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delay.

Returning unrequested attributes sounds like unlikely behavior, but may
as well check for it, sure....  Applying.

--b.

On Thu, Aug 14, 2014 at 11:02:26AM +0530, Srikrishan Malik wrote:
> Signed-off-by: Srikrishan Malik <srimalik@in.ibm.com>
> ---
>  nfs4.0/servertests/st_getattr.py |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.0/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
> index a55b923..6a4acdd 100644
> --- a/nfs4.0/servertests/st_getattr.py
> +++ b/nfs4.0/servertests/st_getattr.py
> @@ -43,10 +43,14 @@ def _try_empty(t, c, path):
>  def _try_supported(t, env, path):
>      c = env.c1
>      mandatory = sum([attr.mask for attr in env.attr_info if attr.mandatory])
> +    all = sum([attr.mask for attr in env.attr_info])
>      supported = c.supportedAttrs(path)
>      if mandatory & supported != mandatory:
>          t.fail("GETATTR(FATTR4_SUPPORTED_ATTRS) did not return "
>                 "all mandatory attributes")
> +    if supported > all:
> +        t.fail("GETATTR(FATTR4_SUPPORTED_ATTRS) returned more than expected "
> +               "supported attributes for the protocol")
>  
>  def _try_long(env, path):
>      c = env.c1
> -- 
> 1.7.1
> 
