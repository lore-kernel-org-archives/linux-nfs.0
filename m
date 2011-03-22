Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:48594 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab1CVWjF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 18:39:05 -0400
Subject: Re: [PATCH] nfs4: Fix memory corruption due to not expected
 FS_LOCATIONS v3
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1300830411.9442.49.camel@lade.trondhjem.org>
References: <1300829795-17054-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1300830411.9442.49.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 01:39:01 +0300
Message-ID: <1300833541.17103.40.camel@vT510>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-03-22 at 17:46 -0400, Trond Myklebust wrote:

> Why are you limiting this to fs_locations?

Sorry, I haven't seen any other attribute that can cause memory
corruption.

>  As I believe I said earlier,
> any attribute that we didn't explicitly request is an error and can
> cause corruption in the client.

There are checks on each decode attr function. For instance,
decode_attr_filehandle:

 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILEHANDLE - 1U)))
		return -EIO;

So any non handled attribute raise EIO error.

> 
> If we're going to fix this, we should fix all potential occurrences once
> and for all.

Yes, I agree. Could you direct that I missed ?

> 

-- 
Thanks,
Vitaliy Gusev

