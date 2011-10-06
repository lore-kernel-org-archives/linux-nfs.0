Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41398 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758253Ab1JFQqd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 12:46:33 -0400
Date: Thu, 6 Oct 2011 12:46:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>,
        "Kirill A. Shutemov" <kas@openvz.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: network-namespace-aware nfsd
Message-ID: <20111006164632.GC21627@fieldses.org>
References: <20111005150214.GA18449@fieldses.org>
 <4E8C9363.9030303@parallels.com>
 <20111005181959.GB18449@fieldses.org>
 <4E8D7BED.6020705@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4E8D7BED.6020705@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 06, 2011 at 01:59:09PM +0400, Stanislav Kinsbursky wrote:
> 05.10.2011 22:19, J. Bruce Fields пишет:
> >To start with I suspect it would be OK to share the one lockd thread.
> >
> 
> Yep, I think so too. It just will be harder to implement.

Why do you think it will be harder to implement?

There may be something about how tasks and namespaces interact that I'm
missing here....

To me it seems like either way we're going to have to add the network
namespace as an argument to any data structure lookups that we're doing,
and it doesn't really matter whether we get the namespace out of the
svc_rqst or someplace else.

--b.
