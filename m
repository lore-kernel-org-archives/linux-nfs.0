Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:55222 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbaD1Fy1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 01:54:27 -0400
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 15:54:26 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 00/22]  New ACL format for better NFSv4 acl interoperability
In-Reply-To: <20140428043909.GA26778@infradead.org>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20140428043909.GA26778@infradead.org>
Date: Mon, 28 Apr 2014 11:24:08 +0530
Message-ID: <87wqeaatj3.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig <hch@infradead.org> writes:

> This doesn't address any or the previous points:
>
>  - common implementation instead of the godawful boilerplate code
>    (and we even fixed most of this for Posix ACL by now, so even less
>    reason to do the same crap again!)

We already do that with richacl. Richacl already have most of the
details implemented in common code. Comparing to recent posix acl
changes we could still simplify chmod and xattr bits. I will do that
in the next update. 

>  - common data structure with Posix ACLs
>

Can you explain this ?. Why do we want to do that ? 


> And of course no real explanation why we need the braindead access/deny
> scheme at how it will get properly integrated with the system.
>
> So in this for a clear NAK.

-aneesh

