Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:32803 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996Ab2AINMO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 08:12:14 -0500
Message-ID: <4F0AE7A4.8020003@itwm.fraunhofer.de>
Date: Mon, 09 Jan 2012 14:12:04 +0100
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
CC: linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        "J. Bruce Fields" <bfields@redhat.com>, sandeen@redhat.com,
        adilger@whamcloud.com
Subject: Re: [PATCH 4 4/4] nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)
References: <20120109101628.2218398.94904.stgit@localhost.localdomain> <20120109101649.2218398.23334.stgit@localhost.localdomain>
In-Reply-To: <20120109101649.2218398.23334.stgit@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/09/2012 11:16 AM, Bernd Schubert wrote:
>   #define NFSD_MAY_BYPASS_GSS		0x400
>   #define NFSD_MAY_READ_IF_EXEC		0x800
>
> +#define NFSD_MAY_64BIT_COOKIE	2048 /* 64 bit readdir cookies for>= NFSv3 */
> +

Oh, I just notice the format of the flags has been updated in the mean 
time and the value for NFSD_MAY_64BIT_COOKIE needs to be increased to 
avoid an conflict.
Will send a new series in a moment.

Sorry for not noticing it earlier,
Bernd

