Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37376 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750891AbdBWLY0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 06:24:26 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "Trond Myklebust" <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFS: Always send an unlock for FL_CLOSE
Date: Thu, 23 Feb 2017 06:24:22 -0500
Message-ID: <CAAA038D-9EB0-46B2-8EE3-A655B0353656@redhat.com>
In-Reply-To: <1487791212.7731.6.camel@redhat.com>
References: <cover.1487691345.git.bcodding@redhat.com>
 <72fa3f2a37146d153722d842e9b0d166fe11f1ad.1487691345.git.bcodding@redhat.com>
 <1487769602.2886.15.camel@redhat.com>
 <09B7C044-3622-4898-BEED-0B516BB54FE2@redhat.com>
 <1487778136.5497.1.camel@redhat.com>
 <1487780839.4863.4.camel@primarydata.com>
 <3D0E5D1B-CB46-40B3-AE36-2D7D7B4B9AD1@redhat.com>
 <1487791212.7731.6.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 22 Feb 2017, at 14:20, Jeff Layton wrote:
> Well, that's where their immediate pain point is. If they have
> applications that are relying on NLM locking to serialize access to 
> the
> files, then this could potentially corrupt their file data.
>
> It may be that no one would ever notice, but those sorts of bug 
> reports
> can be very difficult to track down. If we can fix this in a way that
> works across versions, then that's what I'd suggest.

OK, then it occurs to me that we can do this by passing in a new struct
nlmclnt_operations to nlmclnt_proc().  That can be used to supply a 
function
that should be called in rpc_task_prepare to check the iocounter.  Then 
a
global FL_CLOSE rpc_wait_queue could be used, but I probably wouldn't 
want to
wake it on every iocounter reaching zero - probably only if a lock 
context
has a flag.. or maybe there's another way to tell.

Those operations would also help further abstract NLM from NFS by adding
functions to extract the rpc_cred from the file, and obtain the file 
handle and
owner from the file.  Right now, there's some NFS stuff leaking into the 
NLM
client.

Ben
