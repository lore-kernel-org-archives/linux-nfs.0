Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48139 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab1ING2o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 02:28:44 -0400
Received: by wwf22 with SMTP id 22so1766275wwf.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 23:28:43 -0700 (PDT)
Message-ID: <4E704999.1060205@tonian.com>
Date: Wed, 14 Sep 2011 08:28:41 +0200
From: Benny Halevy <bhalevy@tonian.com>
To: tao.peng@emc.com
CC: rees@umich.edu, linux-nfs@vger.kernel.org
Subject: Re: NULL pointer dereference during mount
References: <F19688880B763E40B28B2B462677FBF805C3299FFE@MX09A.corp.emc.com>,<20110913124202.GA9498@merit.edu> <F19688880B763E40B28B2B462677FBF805C3F37B8D@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C3F37B8D@MX09A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
