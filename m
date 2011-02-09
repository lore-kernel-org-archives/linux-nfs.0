Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43793 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755828Ab1BIAJW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 19:09:22 -0500
Date: Tue, 8 Feb 2011 19:09:21 -0500
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Txema Heredia <txema.heredia@upf.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 memory allocation bug?
Message-ID: <20110209000921.GA13617@fieldses.org>
References: <4D2DE18D.40604@upf.edu>
 <20110112183557.GB11718@fieldses.org>
 <4D2F1ECA.50703@upf.edu>
 <20110113161913.GG20946@fieldses.org>
 <4D2F3583.8090502@upf.edu>
 <20110113180534.GK20946@fieldses.org>
 <4D303D55.1080908@upf.edu>
 <B5CA5C80A1BA4CFAA7CBB56F752F6337@ws075402>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B5CA5C80A1BA4CFAA7CBB56F752F6337@ws075402>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 08, 2011 at 07:07:08PM +0100, Txema Heredia wrote:
> Hi all,
> 
> After a month or so struggling with this, and some other problems with NFSD
> in my "old" kernel (2.6.16.60-0.39.3-smp) related with MTUs larger than 1500
> stalling the server, I think I have found something related with my
> inability to serve v4 filesystems:
> 
> In /usr/src/linux/include/linux/nfsd/const.h there is this defined:
> /*
>  * Maximum protocol version supported by knfsd
>  */
> #define NFSSVC_MAXVERS          3
> 
> And in /usr/src/linux/fs/nfsd/nfsctl.c we can find this:
> err = -EINVAL;
> if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
>    goto out;
> ...
> out:
>         return err;
> 
> 
> And I found exactly the same in 2.6.34.7
> 
> Is this "real" or some old thing that is no longer used and I shouldn't
> worry about?

Probably irrelevant.

Could you tell us exactly what you've tried to do and why it's failing?

--b.
