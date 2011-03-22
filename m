Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62839 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755578Ab1CVXLE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 19:11:04 -0400
Subject: Re: [PATCH] nfs4: Fix memory corruption due to not expected
 FS_LOCATIONS v3
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1300833541.17103.40.camel@vT510>
References: <1300829795-17054-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1300830411.9442.49.camel@lade.trondhjem.org>
	 <1300833541.17103.40.camel@vT510>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Mar 2011 19:10:47 -0400
Message-ID: <1300835447.22796.21.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 01:39 +0300, Vitaliy Gusev wrote:
> On Tue, 2011-03-22 at 17:46 -0400, Trond Myklebust wrote:
> 
> > Why are you limiting this to fs_locations?
> 
> Sorry, I haven't seen any other attribute that can cause memory
> corruption.

decode_attr_filehandle() will certainly cause an Oops if someone inserts one.

There may be more occurrences in the future if/when we need to add
support for more attributes.

> >  As I believe I said earlier,
> > any attribute that we didn't explicitly request is an error and can
> > cause corruption in the client.
> 
> There are checks on each decode attr function. For instance,
> decode_attr_filehandle:
> 
>  	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILEHANDLE - 1U)))
> 		return -EIO;
> 
> So any non handled attribute raise EIO error.

If we're going to do this, then I suggest we add an 'expected bitmask'
argument to 'decode_attr_bitmap()'. If the server sets any bit that is
not part of this expected bitmask, then we can immediately return an EIO
without having to decode any further.

That will allow us to get rid of the 'if (unlikely(bitmap[] & ....)'
tests altogether.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

