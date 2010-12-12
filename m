Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:45410 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753827Ab0LLTFb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Dec 2010 14:05:31 -0500
Subject: Re: [nfsv4] Question about NFS41 server attributes changes
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "P.B.Shelley" <shelleypt@gmail.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>, nfsv4 <nfsv4@ietf.org>
In-Reply-To: <AANLkTimDjL8GmU64RJfrtJxdhemziYKrjpSTHoemzR0k@mail.gmail.com>
References: <AANLkTimDjL8GmU64RJfrtJxdhemziYKrjpSTHoemzR0k@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 12 Dec 2010 14:05:25 -0500
Message-ID: <1292180725.6847.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-12-12 at 00:39 +0800, P.B.Shelley wrote:
> Hi,
> 
> I have a questions about NFS41 server attributes. The protocol defines
> clearly in section 5.6 which attributes are modifiable by client and
> which are not. But it is not clear on which attributes are modifiable
> by server or not. Take the fs_layout_type and layout_blksize attribute
> as an example. Can server change them at any time? What should client
> do if server changes some attributes on its own?
> 

For something like the fs_layout_type, the client should expect the
server to recall all layouts that may be affected by the change.

For most variables, however, the client should be aware that they can
change, and is expected to revalidate them by polling at regular
intervals.
fs_locations and security policy changes can also be detected by polling
the policy_change attribute (if supported on the server).

Cheers
  Trond

