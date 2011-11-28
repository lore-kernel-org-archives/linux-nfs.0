Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:40536 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab1K1VJg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 16:09:36 -0500
Date: Mon, 28 Nov 2011 13:09:30 -0800
From: Tejun Heo <tj@kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Jeff Layton <jlayton@redhat.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org, john@calva.com,
        trond.myklebust@netapp.com, marek.belisko@gmail.com,
        awilliam@redhat.com
Subject: Re: [PATCH v3 0/2] nfs/sunrpc: allow freezing of tasks with NFS
 calls in flight
Message-ID: <20111128210930.GA3858@google.com>
References: <1322510488-21189-1-git-send-email-jlayton@redhat.com>
 <201111282122.53635.rjw@sisk.pl>
 <20111128204024.GH18864@google.com>
 <201111282207.07098.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201111282207.07098.rjw@sisk.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Mon, Nov 28, 2011 at 10:07:06PM +0100, Rafael J. Wysocki wrote:
> The point is to let the patches stay in linux-next for a couple of days
> before moving them to the pm-freezer branch to see if there's any fallout (I'm
> not going to rebase pm-freezer, so fixing it will require addtional commits).

Ah.. thanks for the explanation.  Yeah, I'm planning on pulling
freezer changes into cgroup for cgroup-freezer updates as doing it
separately seems to cause a lot of rather unnecessary conflicts so
keeping the branch stable would definitely be nice.

Thanks.

-- 
tejun
