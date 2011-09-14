From: Benny Halevy <bhalevy@tonian.com>
Subject: Re: NULL pointer dereference during mount
Date: Wed, 14 Sep 2011 08:31:23 +0200
Message-ID: <4E704A3B.7080504@tonian.com>
References: <F19688880B763E40B28B2B462677FBF805C3299FFE@MX09A.corp.emc.com>,<20110913124202.GA9498@merit.edu> <F19688880B763E40B28B2B462677FBF805C3F37B8D@MX09A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rees@umich.edu, linux-nfs@vger.kernel.org
To: tao.peng@emc.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39860 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab1INGb3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 02:31:29 -0400
Received: by wwf22 with SMTP id 22so1768994wwf.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 23:31:28 -0700 (PDT)
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C3F37B8D-AYrsSIZi/B2B3McK65YKY9BPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I couldn't reproduce this with selinux neither disabled nor enforcing.
What's your selinux configuration?

Benny

On 2011-09-13 18:43, tao.peng@emc.com wrote:
> 
> ________________________________________
> From: Jim Rees [rees@umich.edu]
> Sent: Tuesday, September 13, 2011 8:42 PM
> To: Peng, Tao
> Cc: bhalevy@tonian.com; linux-nfs@vger.kernel.org
> Subject: Re: NULL pointer dereference during mount
> 
> tao.peng@emc.com wrote:
> 
>   After rebasing to your pnfs-all-latest branch, I always got bellow NULL
>   pointer dereference for both nfsv4 and pnfs. Do you know of any recent
>   change that can cause this?
> 
> "git diff" shows no change in the nfs client between my for-benny branch and
> benny's pnfs-all-latest branch.  And the mount works for me.  But the first
> thing I always do on a fresh Fedora install is disable selinux.  Maybe
> something changed in selinux?
> [PT] Just tested 3.1-rc6 and it is working properly. So I think it should be caused by nfs changes.--
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
