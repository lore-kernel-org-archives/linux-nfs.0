Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47218 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539AbbIISsS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2015 14:48:18 -0400
Date: Wed, 9 Sep 2015 14:48:17 -0400
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: nfsv4@ietf.org, linux-nfs@vger.kernel.org
Subject: Re: NFSv4.2 wireshark
Message-ID: <20150909184817.GA25750@fieldses.org>
References: <20150909174508.GA2445@skull>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150909174508.GA2445@skull>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 09, 2015 at 10:45:08AM -0700, Tom Haynes wrote:
> I've contributed the remaining changes needed to have wireshark decode NFSv4.2:
> 
> 8a8a82d nfs: Add NFSv4.2 op LAYOUTERROR
> 0c6b54e nfs: Add support for the Flex File Layout Type in LAYOUTRETURN
> 0f89e42 nfs: Add NFSv4.2 op LAYOUTSTATS
> 6b59566 nfs: Add NFSv4.2 op WRITE_SAME
> 0fdd702 nfs: Add NFSv4.2 op READ_PLUS
> 720a759 nfs: Add NFSv4.2 cb op CB_OFFLOAD
> 9e07406 nfs: Add NFSv4.2 op IO_ADVISE
> b5aa0ff nfs: Add NFSv4.2 ops OFFLOAD_CANCEL and OFFLOAD_STATUS
> c782824 nfs: Add NFSv4.2 op CLONE
> 2160e9c nfs: Add NFSv4.2 ops COPY and COPY_NOTIFY
> 79b88aa nfs: Cleanup of FlexFiles Layout Type
> 6e82854 nfs: Add new attributes for NFSv4.2
> a79967f nfs: Add new error codes for NFSv4.2
> 
> These are in the bleeding edge 1.99.9:
> 
> git clone https://code.wireshark.org/review/wireshark
> 
> I have no idea when these will pop into the mainstream.
> 
> Note, they do build on earlier changes I provided and those
> also are in the bleeding edge and not in the mainstream.

Excellent, thanks!

--b.
