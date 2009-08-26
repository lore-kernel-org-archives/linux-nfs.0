Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:60588 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbZHZO2j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 10:28:39 -0400
Cc: NFS list <linux-nfs@vger.kernel.org>
Message-Id: <3644941A-3EA7-4755-867A-888E81A372FC@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Lans Carstensen <Lans.Carstensen@dreamworks.com>
In-Reply-To: <4A94C133.8030904@dreamworks.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH 2/4] nfs-utils: nfs-iostat.py autofs cleanup and option to sort by ops/s
Date: Wed, 26 Aug 2009 10:28:26 -0400
References: <4A94C133.8030904@dreamworks.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 26, 2009, at 12:59 AM, Lans Carstensen wrote:

> commit d3bb692a8c26c2d4e0dc70d7d0359daf79090e1e
> Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
> Date:   Tue Aug 25 21:52:03 2009 -0700
>
>    Bump nfs-iostat.py version up to 0.3 to reflect new features.

Now that nfs-iostat.py has been integrated into nfs-utils, I'm not  
sure we want to maintain an individual version number for it.  Maybe  
it should use the nfs-utils package's versioning instead... Steve,  
your thoughts?

> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
> iostat.py
> index ea02db4..6ce31fc 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -22,7 +22,7 @@ Foundation, Inc., 59 Temple Place, Suite 330,  
> Boston, MA 02111-1307 USA
>
> import sys, os, time
>
> -Iostats_version = '0.2'
> +Iostats_version = '0.3'
>
> def difference(x, y):
>     """Used for a map() function
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



