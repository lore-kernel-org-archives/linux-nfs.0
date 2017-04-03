Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751692AbdDCJoX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Apr 2017 05:44:23 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>, bfields@fieldses.org,
        "Miklos Szeredi" <miklos@szeredi.hu>,
        "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3/6] locks: Set FL_CLOSE when removing flock locks on
 close()
Date: Mon, 03 Apr 2017 05:44:21 -0400
Message-ID: <BCA70904-F0D2-4F73-A079-631603ED49D1@redhat.com>
In-Reply-To: <1491054638.18117.4.camel@redhat.com>
References: <cover.1491015671.git.bcodding@redhat.com>
 <263565f7e1c80222c10c8102fc112f1ce97ccfe8.1491015671.git.bcodding@redhat.com>
 <1491054638.18117.4.camel@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1 Apr 2017, at 9:50, Jeff Layton wrote:

> On Fri, 2017-03-31 at 23:16 -0400, Benjamin Coddington wrote:
>> Set FL_CLOSE in fl_flags as in locks_remove_posix() when clearing locks.
>> NFS will check for this flag to ensure an unlock is sent in a following
>> patch.
>>
>
> Might be nice to add some verbiage here about why fuse needs to be
> changed, just for posterity. I recall the discussion a while back so I
> think the change itself looks fine.

OK, I'll do that.

Ben
