Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:47602 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864Ab1C3RLb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Mar 2011 13:11:31 -0400
Received: by pvg12 with SMTP id 12so231730pvg.19
        for <linux-nfs@vger.kernel.org>; Wed, 30 Mar 2011 10:11:31 -0700 (PDT)
Message-ID: <4D936453.2070501@panasas.com>
Date: Wed, 30 Mar 2011 19:11:47 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Christoph Hellwig <hch@lst.de>
CC: Rees <rees@citi.umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [RFC] spnfs-block: restore i_op->fallocate
References: <1301500460-16467-1-git-send-email-bhalevy@panasas.com> <20110330155811.GA21931@lst.de>
In-Reply-To: <20110330155811.GA21931@lst.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-03-30 17:58, Christoph Hellwig wrote:

> On Wed, Mar 30, 2011 at 05:54:20PM +0200, Benny Halevy wrote:
>> spnfsd-blocks needs the old inode_operations API for fallocate
>> as it does not have a struct_file in hand.
>>
>> As all file systems (but xfs) currently use the struct file argument
>> to get to the inode move their implementation back into a inode operation.
>> Introduce generic_file_fallocate that can be used as the file_operations
>> method that just does that and calls i_op->fallocate.
>>
>> Refactor the xfs implementation and introduce _xfs_vn_fallocate
>> that takes an addition attr_flags, which value depends on the struct file
>> argument to xfs_file_fallocate.
> NAK.  Not only isn't spnfsd-block not upstream, but I probably never will be
> given what a piece of junk it is.
>
> Second making fallocate a file operation was done on purpose, and all the

I understand that from the API perspective but note that other than O_SYNC
there's no use for the struct file * passed in.

> other filesystem need the same fix that xfs has - making the allocation
> stable if done on an O_SYNC file descriptor.

Makes sense. This could also be done by adding a respective flags argument
to fallocate and have a common wrapper function look at the file descriptor
and call the fs fallocate, that could then get the inode rather the file.
In other words, why copy code rather than factor it out into a common
function?

Benny

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

