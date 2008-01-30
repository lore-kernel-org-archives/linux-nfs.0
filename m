From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/4] NFS: Show most mount options via nfs_show_options()
Date: Wed, 30 Jan 2008 16:58:46 -0500
Message-ID: <A00EE326-978A-42AE-9541-8F41F3A1CE5C@oracle.com>
References: <20080130001333.14637.74159.stgit@manray.1015granger.net> <E1JKCOe-0008Dg-2p@pomaz-ex.szeredi.hu>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:20480 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbYA3V7S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2008 16:59:18 -0500
In-Reply-To: <E1JKCOe-0008Dg-2p-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Miklos-

On Jan 30, 2008, at 7:50 AM, Miklos Szeredi wrote:
>> Display all mount options in /proc/mount which may be needed to  
>> reconstruct
>> a previous mount.
>
> Thanks, looks good to me.  The only thing I see still missing is
> "mounthost".  What about that one?


User space (the mount.nfs command) converts "mounthost=" to  
"mountaddr=".  /proc/mounts shows "mountaddr=" so redriving the mount  
request will just pass that back in.

Currently, none of the DNS resolutions are redone on an NFS remount.   
The original "addr=" "clientaddr=" and "mountaddr=" options are  
reused, even with /etc/mtab.

(I'm not editorializing about whether that's right or wrong, but that  
is my understanding of how it works today).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
