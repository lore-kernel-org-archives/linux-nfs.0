Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lisa.pbhware.com ([96.251.22.156]:47516 "EHLO lisa.pbhware.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726448AbeHVEle (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Aug 2018 00:41:34 -0400
Subject: Re: nfs4-acl-tools 0.3.5
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <20180807193736.GA18187@fieldses.org>
 <20180821165130.GA14413@fieldses.org>
 <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
 <20180822003301.GA17500@fieldses.org>
From: "Paul B. Henson" <henson@acm.org>
Message-ID: <d4649560-ad74-d119-13ba-876af9a4974e@acm.org>
Date: Tue, 21 Aug 2018 18:18:49 -0700
MIME-Version: 1.0
In-Reply-To: <20180822003301.GA17500@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/21/2018 5:33 PM, J. Bruce Fields wrote:

> In the wire protocol there's no need for such constants.  An ACE can
> have one of the special strings OWNER@, GROUP@, or EVERYONE@ in the
> owner field, and that's all you need.

Ah, so an NFSv4 client is supposed to figure out whether or not it's a 
special ACE just by the who_string... That probably explains why I 
didn't see the same issue using the nfs4-acl-tools on a Linux client 
mounting an illumos ZFS share via NFS.

> The only use of those constants is probably internal to the ACL tools,
> so they don't have to agree with any standards.

Ok, I found the illumos NFSv4 server code where it converts the local 
ZFS ACLs to/from xdr format, and you're right, those flags are not 
included in the outbound mapping, it converts them to the special entry 
strings, and it does string comparisons to determine whether or not to 
add them for the inbound mapping.

However, in the nfs4-acl-tools code it seems to expect those bits off 
the wire to decode and is willing to send them on the wire?

For example, in libnfs4acl/nfs4_get_ace_flags.c

if (flags & NFS4_ACE_OWNER)
         *buf++ = FLAG_OWNER_AT;

If it sees that bit set in the flags, it adds 'O' to the string 
representation, and correspondingly in libnfs4acl/nfs4_ace_from_string.c:

case FLAG_OWNER_AT:
         flags |= NFS4_ACE_OWNER;
         break;

If you include O in your ACL specification, it will add that flag and 
include it when it sends it? The same for the NFS4_ACE_GROUP and 
NFS4_ACE_EVERYONE flags.

I'm confused why the nfs4-acl-tools would need these local defines. On 
the ZFS side, the on-disk ACL format doesn't include strings, just flags 
and uids/gids, so the extra flag bits are presumably needed so it can 
tell which entries are special. However, the tools presumably are only 
intended to consume NFSv4 xdr, and generate it? So why did they need 
these flags given that the NFSv4 xdr format doesn't include them?

Thanks for the input, much appreciated…
