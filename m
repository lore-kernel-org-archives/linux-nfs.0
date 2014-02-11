Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49999 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285AbaBKRIm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Feb 2014 12:08:42 -0500
Date: Tue, 11 Feb 2014 12:08:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH pynfs] nfs4.1 server: DSs should have diff server owners
Message-ID: <20140211170842.GE19599@fieldses.org>
References: <1392050222-1470-1-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1392050222-1470-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 10, 2014 at 11:37:02AM -0500, Weston Andros Adamson wrote:
> Use getpid() to generate the minor_id component of the server owner.
> 
> Witout this, all DSs are considered to be the same server by NFS clients
> that detect server trunking, such as the upstream Linux client.

Applied and pushed out, thanks.--b.

> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>  nfs4.1/config.py | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/nfs4.1/config.py b/nfs4.1/config.py
> index 4f91e84..2238aee 100644
> --- a/nfs4.1/config.py
> +++ b/nfs4.1/config.py
> @@ -3,6 +3,7 @@ from nfs4_const import *
>  import nfs4_const
>  import nfs4lib
>  from copy import deepcopy
> +import os
>  
>  class ConfigAction(Exception):
>      pass
> @@ -129,7 +130,7 @@ class ServerConfig(object):
>                ]
>  
>      def __init__(self):
> -        self.minor_id = 0
> +        self.minor_id = os.getpid()
>          self.major_id = "PyNFSv4.1"
>          self._owner = server_owner4(self.minor_id, self.major_id)
>          self.scope = "Default_Scope"
> -- 
> 1.8.3.4 (Apple Git-47)
> 
