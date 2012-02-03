Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:40163 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852Ab2BCAKF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Feb 2012 19:10:05 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Rt6j5-00064c-6G
	for linux-nfs@vger.kernel.org; Fri, 03 Feb 2012 01:10:03 +0100
Received: from 78-60-211-195.static.zebra.lt ([78.60.211.195])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 03 Feb 2012 01:10:03 +0100
Received: from grawity by 78-60-211-195.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 03 Feb 2012 01:10:03 +0100
To: linux-nfs@vger.kernel.org
From: Mantas <grawity@gmail.com>
Subject: Re: could modify sillyrename to put files in /tmp
Date: Fri, 03 Feb 2012 02:07:25 +0200
Message-ID: <jgf8ft$rg5$1@dough.gmane.org>
References: <201202021018234324363@300.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
In-Reply-To: <201202021018234324363@300.cn>
Cc: linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-02-02 04:18, wangjing wrote:
> In nfs v3 ,if mulity process visit nfs mount nfs dir ,there sometimes occour .nfsXXX can't delete .
> 
> If modify sillyrename to put files in /tmp ,it will be more friendly to nfs user.

What would then happen if /tmp was on a separate filesystem than the
original file?

> the background
>    1、Linux fs has   /nfsmnt/work_pub/web and /nfsmnt/work_inwork/web ，they use NFS V3 mount
>    2、there is many process will read and write files in the dir /nfsmnt/work_pub/web 
>    3、cron will del  all files in dir  /nfsmnt/work_pub/web in period，and will copy all the files which in the dir /nfsmnt/work_inwork/web 
> 
> in some times delete all files in  /nfsmnt/work_pub/web will faild ,because there is some .nfsXXXX

Then modify the cron job to ignore ".nfs*" files.

-- 
Mantas M.

