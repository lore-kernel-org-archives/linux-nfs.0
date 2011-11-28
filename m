Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:35145 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab1K1Ukb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 15:40:31 -0500
Date: Mon, 28 Nov 2011 12:40:24 -0800
From: Tejun Heo <tj@kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Jeff Layton <jlayton@redhat.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org, john@calva.com,
        trond.myklebust@netapp.com, marek.belisko@gmail.com,
        awilliam@redhat.com
Subject: Re: [PATCH v3 0/2] nfs/sunrpc: allow freezing of tasks with NFS
 calls in flight
Message-ID: <20111128204024.GH18864@google.com>
References: <1322510488-21189-1-git-send-email-jlayton@redhat.com>
 <201111282122.53635.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201111282122.53635.rjw@sisk.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 28, 2011 at 09:22:53PM +0100, Rafael J. Wysocki wrote:
> If no one objects, I'll take these patches to linux-pm/linux-next in the
> next couple of days (and then to the pm-freezer branch, if there are no
> visible problems with them).

Rafael, I think these need to be routed through pm-freezer branch.
Freezer went through a lot of changes and I don't think this will work
reliably without the freezer changes.

Thanks.

-- 
tejun
