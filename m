Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab1IWS5o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 14:57:44 -0400
Date: Fri, 23 Sep 2011 14:57:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 1/6] leases: split up generic_setlease into lock/unlock
 cases
Message-ID: <20110923185728.GC807@pad.fieldses.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
 <1316617097-21384-2-git-send-email-bfields@redhat.com>
 <1316711774.3159.52.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1316711774.3159.52.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 22, 2011 at 01:16:14PM -0400, Mimi Zohar wrote:
> On Wed, 2011-09-21 at 10:58 -0400, J. Bruce Fields wrote: 
> > Eventually we should probably do the same thing to the file operations
> > as well.
...
> Nice, the code refactoring makes it a lot more readable.

Thanks.  I'm assuming this one is uncontroversial, so I'll go ahead and
add it to my for-3.2 tree soon.

--b.
