Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36188 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965651AbcKLMyO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2016 07:54:14 -0500
Received: by mail-qk0-f173.google.com with SMTP id n21so49455091qka.3
        for <linux-nfs@vger.kernel.org>; Sat, 12 Nov 2016 04:54:13 -0800 (PST)
Message-ID: <1478955250.2442.16.camel@redhat.com>
Subject: Re: CLOSE/OPEN race
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Date: Sat, 12 Nov 2016 07:54:10 -0500
In-Reply-To: <9E2B8A0D-7B0E-4AE5-800A-0EF3F7F7F694@redhat.com>
References: <9E2B8A0D-7B0E-4AE5-800A-0EF3F7F7F694@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-11-12 at 06:08 -0500, Benjamin Coddington wrote:
> I've been seeing the following on a modified version of generic/089
> that gets the client stuck sending LOCK with NFS4ERR_OLD_STATEID.
> 
> 1. Client has open stateid A, sends a CLOSE
> 2. Client sends OPEN with same owner
> 3. Client sends another OPEN with same owner
> 4. Client gets a reply to OPEN in 3, stateid is B.2 (stateid B sequence 2)
> 5. Client does LOCK,LOCKU,FREE_STATEID from B.2
> 6. Client gets a reply to CLOSE in 1
> 7. Client gets reply to OPEN in 2, stateid is B.1
> 8. Client sends LOCK with B.1 - OLD_STATEID, now stuck in a loop
> 
> The CLOSE response in 6 causes us to clear NFS_OPEN_STATE, so that the OPEN
> response in 7 is able to update the open_stateid even though it has a lower
> sequence number.
> 
> I think this case could be handled by never updating the open_stateid if the
> stateids match but the sequence number of the new state is less than the
> current open_state.
> 

What kernel is this on?

Yes, that seems wrong. The client should be picking B.2 for the open
stateid to use. I think that decision of whether to take a seqid is made
in nfs_need_update_open_stateid. The logic in there looks correct to me
at first glance though.

-- 
Jeff Layton <jlayton@redhat.com>
