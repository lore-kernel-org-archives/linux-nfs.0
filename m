Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:42391 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747Ab1IMEZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 00:25:55 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: David Howells <dhowells@redhat.com>
Cc: dhowells@redhat.com, agruen@kernel.org, bfields@fieldses.org,
        akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 25/26] ext4: Implement rich acl for ext4
In-Reply-To: <25112.1315572358@redhat.com>
References: <1315243548-18664-26-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <25112.1315572358@redhat.com>
Date: Tue, 13 Sep 2011 09:55:30 +0530
Message-ID: <87zki99ih1.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 09 Sep 2011 13:45:58 +0100, David Howells <dhowells@redhat.com> wrote:
> Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > +	retval = ext4_set_richacl(handle, inode, acl);
> > +	ext4_journal_stop(handle);
> > +	if (retval == ENOSPC && ext4_should_retry_alloc(inode->i_sb, &retries))
> > +		goto retry;
> 
> Should that be -ENOSPC?

Fixed 

> 
> I do wonder, why does ext4 need to know about richacls at all?  Surely, as far
> as ext4 is concerned, they should be seen as xattrs?
> 

richacl related changes to ext4 is minimal. They mostly are to call
necessary permission check functions and to map xattr to richacl
structure.


> If ext4 needs a mark on disk to say it supports richacls, then why can't that
> simply be the presence or lack thereof of a richacl on the root dir?
> 

I have a patch in the full series which enable richacl on ext4 file system
based on ext4 compatibility flags. I didn't add that as a part of this
series to enable easy testing. The goal is to use tune2fs to enable
richacl and them the mount option -o acl enable richacl/posix acl
accordingly. 

-aneesh
