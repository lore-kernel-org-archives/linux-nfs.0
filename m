Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25753 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752433AbcKCXMg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Nov 2016 19:12:36 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Jeff Layton" <jlayton@redhat.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/6] NFSv4: change nfs4_do_setattr to take an open_context
 instead of a nfs4_state.
Date: Thu, 03 Nov 2016 19:12:33 -0400
Message-ID: <D2F33163-B3FA-4678-81E4-F1D81FB830A1@redhat.com>
In-Reply-To: <82FF393E-B8F1-4357-9DBC-F467F7082DB7@redhat.com>
References: <147633263771.766.17853370901003798934.stgit@noble>
 <147633280745.766.9047567139865023402.stgit@noble>
 <0773ADA2-C1DE-4D01-8B3C-5883A6A62C2E@redhat.com>
 <877f8lqwv3.fsf@notabene.neil.brown.name>
 <82FF393E-B8F1-4357-9DBC-F467F7082DB7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3 Nov 2016, at 12:38, Benjamin Coddington wrote:
> The network capture isn't very enlightening.. or I haven't been able 
> to find
> where the problem happens in the 800Mb of capture.  I probably need to 
> make
> the box panic on oops and capture externally so the problem is right 
> at the
> end of the capture.  I'll keep plugging away at this as I can.

I just got this on v4.9-rc1 without these patches, so false alarm here.  
Sorry
for the noise.  I'll see if I can bisect.

Ben
