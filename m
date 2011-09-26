Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40115 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab1IZQQW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 12:16:22 -0400
Date: Mon, 26 Sep 2011 12:16:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Stefan (metze) Metzmacher" <metze@samba.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-fsdevel@vger.kernel.org,
        Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: breaking leases on metadata changes
Message-ID: <20110926161616.GD16044@fieldses.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
 <4E7E2314.6000101@samba.org>
 <20110926141027.GB16044@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110926141027.GB16044@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 26, 2011 at 10:10:27AM -0400, J. Bruce Fields wrote:
> Anyway, if this is all correct then it sounds like v4 read delegations
> and level 2 oplocks may be more different than I'd thought.

By the way, another ignorant question: poking around SMB2 documentation
I see that there are both "oplocks" and "leases".  What's the
relationship between them, and which of them should map to Linux leases?

--b.
