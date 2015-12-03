Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34297 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039AbbLCT3M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2015 14:29:12 -0500
MIME-Version: 1.0
In-Reply-To: <20151203103035.GA15996@lst.de>
References: <1448563859-21922-1-git-send-email-hch@lst.de> <CAH2r5muW6=v6tx3BwXSYMgn7EZgzVANniebsxfwpdq9Y=0VcuA@mail.gmail.com>
 <20151202072757.GB15839@lst.de> <CAH2r5msWk+oA=teWnLrpJhp48PEToMoWiN8H8+ptdvEko+GNbA@mail.gmail.com>
 <20151203103035.GA15996@lst.de>
From: Steve French <smfrench@gmail.com>
Date: Thu, 3 Dec 2015 13:28:52 -0600
Message-ID: <CAH2r5mt3fbXGvT6MFFOam91rGziB++Epvs6OpNmWFBhpB3R4Ow@mail.gmail.com>
Subject: Re: vfs: move btrfs clone ioctls to common code
To: Christoph Hellwig <hch@lst.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Peng Tao <tao.peng@primarydata.com>,
        Jeffrey Layton <jeff.layton@primarydata.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 3, 2015 at 4:30 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Wed, Dec 02, 2015 at 11:40:13AM -0600, Steve French wrote:
>> If the copy_file_range is allowed to use any offload mechanism then
>> cifs.ko could be changed as follows, to fallback among the three
>> possible mechanisms depending on what the target supports.
>
> How reliable are the fallbacks?  E.g. for clones we usually have alignment
> restrictions that we'd need to communicate back, and cifs currently
> doesn't have client side checks for those.

I am not worried about fallback inconsistency for the current two options,
if block refcounting is not supported we will know before we issue the
request, and the fallback copy chunk has few restrictions.
When we add ODX there may be additional alignments restrictions, but don't know
until we investigate more.

Although we can query alignment over CIFS and SMB3, it is less important
to know over a network file system than a block device, and unlikely to be
a restriction.  Although the protocol does not restrict the maximum chunk
size, the server can return an error indicating the maximum
supported chunk size, allowing the client to retry with the size of
chunks the server requests.  To match existing server behavior with
reasonable defaults for common servers - the cifs client uses
16 chunks of 1MB each for each FSCTL_SRV_COPYCHUNK_WRITE
request sent on the wire.

-- 
Thanks,

Steve
