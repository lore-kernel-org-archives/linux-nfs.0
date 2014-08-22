Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.18]:64753 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbaHVTsV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Aug 2014 15:48:21 -0400
Message-ID: <53F79E81.4060509@gmx.de>
Date: Fri, 22 Aug 2014 21:48:17 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 0/2] RFC: Fix nfs_generic_pgio page vector issues
References: <1408052373-4306-1-git-send-email-dros@primarydata.com> <BBF98A73-8235-4609-BB95-DC8C900E2134@primarydata.com>
In-Reply-To: <BBF98A73-8235-4609-BB95-DC8C900E2134@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/15/2014 04:36 PM, Weston Andros Adamson wrote:
> This survived a full day of running trinity on one system and a full day of various iozone / fio on another.
> 
> It’s good to go from my perspective.
> 
> -dros
> 
> 

Test passed here too within 32 bit UML guests.



-- 
Toralf

