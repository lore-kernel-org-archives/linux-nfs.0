From: "NeilBrown" <neilb@suse.de>
Subject: Re: RESTRICTED_STATD
Date: Wed, 27 Aug 2008 07:08:33 +1000 (EST)
Message-ID: <88db5e555cc43593e70d0981238e5ef8.squirrel@neil.brown.name>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Steve Dickson" <steved@redhat.com>,
	"Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
To: "Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:38784 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285AbYHZVIl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2008 17:08:41 -0400
In-Reply-To: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, August 27, 2008 6:41 am, Chuck Lever wrote:
> Hi guys-
>
> I was wondering if anyone ever builds nfs-utils with RESTRICTED_STATD
> undefined these days.  It seems totally insecure to do.  Is it still
> necessary to keep this?
>
> It would be easier to understand, update, and test the logic in utils/
> statd/monitor.c (IPv6-wise) if we could remove the unused parts of
> this code.
>
> I propose removing RESTRICTED_STATD, leaving in the secure version of
> the code permanently and removing the insecure parts that are left out
> when RESTRICTED_STATD is undefined.
>
> Thoughts?

I fully agree and support the idea!

NeilBrown

