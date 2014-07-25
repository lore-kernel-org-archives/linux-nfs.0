Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:62001 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbaGYLty (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:49:54 -0400
Received: by mail-qa0-f50.google.com with SMTP id s7so4363048qap.23
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:49:54 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 25 Jul 2014 07:49:52 -0400
To: sheng qiu <herbert1984106@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: pNFS setup
Message-ID: <20140725074952.5362e6fb@tlielax.poochiereds.net>
In-Reply-To: <CAB7xdinUj4U3PAYVB7j3o+iWSTV7aNMBD5O-rAgnzj6vgmce0g@mail.gmail.com>
References: <CAB7xdinUj4U3PAYVB7j3o+iWSTV7aNMBD5O-rAgnzj6vgmce0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 23 Jul 2014 17:12:27 -0700
sheng qiu <herbert1984106@gmail.com> wrote:

> Hi,
> 
> does anyone can share your experience on setting up the pNFS of file
> layout or block layout?
> the wiki instruction :
> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions does
> not work for me on step
> 
> echo "/dev/sdc:192.168.0.1,192.168.0.2" >/proc/fs/nfsd/pnfs_dlm_device
> 
> since i do not have that directory entry after install the pNFS kernel
> version. my system is ubuntu 14.
> 

Take note of "step 0" on that page.

Server-side pNFS patches have not been merged into mainline (yet!).
You'll need a specially patched kernel for that.

-- 
Jeff Layton <jlayton@primarydata.com>
