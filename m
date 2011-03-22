Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:49713 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924Ab1CVXSy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 19:18:54 -0400
Subject: Re: [PATCH] nfs4: Fix memory corruption due to not expected
 FS_LOCATIONS v3
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1300835447.22796.21.camel@lade.trondhjem.org>
References: <1300829795-17054-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1300830411.9442.49.camel@lade.trondhjem.org>
	 <1300833541.17103.40.camel@vT510>
	 <1300835447.22796.21.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 02:18:49 +0300
Message-ID: <1300835929.17103.70.camel@vT510>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-03-22 at 19:10 -0400, Trond Myklebust wrote:
> On Wed, 2011-03-23 at 01:39 +0300, Vitaliy Gusev wrote:
> > On Tue, 2011-03-22 at 17:46 -0400, Trond Myklebust wrote:
> > 
> > > Why are you limiting this to fs_locations?
> > 
> > Sorry, I haven't seen any other attribute that can cause memory
> > corruption.
> 
> decode_attr_filehandle() will certainly cause an Oops if someone inserts one.

Hmm, Thanks! But it seems that here plain check on NULL is enough...

> 
> There may be more occurrences in the future if/when we need to add
> support for more attributes.
> 
> > >  As I believe I said earlier,
> > > any attribute that we didn't explicitly request is an error and can
> > > cause corruption in the client.
> > 
> > There are checks on each decode attr function. For instance,
> > decode_attr_filehandle:
> > 
> >  	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILEHANDLE - 1U)))
> > 		return -EIO;
> > 
> > So any non handled attribute raise EIO error.
> 
> If we're going to do this, then I suggest we add an 'expected bitmask'
> argument to 'decode_attr_bitmap()'. If the server sets any bit that is
> not part of this expected bitmask, then we can immediately return an EIO
> without having to decode any further.
> 
> That will allow us to get rid of the 'if (unlikely(bitmap[] & ....)'
> tests altogether.

You are right. I'll do as you said.

-- 
Thanks,
Vitaliy Gusev

