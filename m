Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60706 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751187AbeC0Q1N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Mar 2018 12:27:13 -0400
Date: Tue, 27 Mar 2018 12:27:11 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Jianhong.Yin" <yin-jianhong@163.com>
Cc: linux-nfs@vger.kernel.org, jiyin@redhat.com
Subject: Re: [PATCH] [pynfs] remove redundant ply, gssapi and rpcgen.py
 modules
Message-ID: <20180327162711.GA13526@parsley.fieldses.org>
References: <20180327064055.9559-1-yin-jianhong@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180327064055.9559-1-yin-jianhong@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hm, I'm getting

Moving to nfs4.0
Traceback (most recent call last):
  File "./setup.py", line 16, in <module>
    import use_local
ImportError: No module named use_local

I guess that's due to this:

On Tue, Mar 27, 2018 at 02:40:55PM +0800, Jianhong.Yin wrote:
> diff --git a/nfs4.0/setup.py b/nfs4.0/setup.py
> index f17a1c9..d5d3ad8 100755
> --- a/nfs4.0/setup.py
> +++ b/nfs4.0/setup.py
> @@ -10,18 +10,20 @@ from distutils.core import setup, Extension
>  from distutils.dep_util import newer_group
>  import os
>  import glob
> +try:
> +    import xdrgen
> +except ImportError:
> +    import use_local
> +    import xdrgen

--b.
