Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:49523 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889AbaJASiB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Oct 2014 14:38:01 -0400
Received: by mail-vc0-f176.google.com with SMTP id hq11so690421vcb.35
        for <linux-nfs@vger.kernel.org>; Wed, 01 Oct 2014 11:38:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <542C067C.7030309@Netapp.com>
References: <1411876498-12039-1-git-send-email-trond.myklebust@primarydata.com>
	<1411876498-12039-2-git-send-email-trond.myklebust@primarydata.com>
	<542C067C.7030309@Netapp.com>
Date: Wed, 1 Oct 2014 14:38:00 -0400
Message-ID: <CAHQdGtTRxTXz16w_+U92UeVXg9Sf+gpHzs3aLxjVOO0JVgSvhg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] NFSv4: Fix lock recovery when CREATE_SESSION/SETCLIENTID_CONFIRM
 fails
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 1, 2014 at 9:49 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> On 09/27/2014 11:54 PM, Trond Myklebust wrote:
>> If a NFSv4.x server returns NFS4ERR_STALE_CLIENTID in response to a
>> CREATE_SESSION or SETCLIENTID_CONFIRM in order to tell us that it rebooted
>> a second time, then the client will currently take this to mean that it must
>> declare all locks to be stale, and hence ineligible for reboot recovery.
>>
>> RFC3530 and RFC5661 both suggest that the client should instead rely on the
>> server to respond to inelegible open share, lock and delegation reclaim
>> requests with NFS4ERR_NO_GRACE in this situation.
> Has our handling of NFS4ERR_NO_GRACE been tested in this situation?

nfs4_reclaim_open_state() will handle it by calling
nfs4_state_mark_reclaim_nograce(), which clears the flags enabling
reboot recovery, and sets the NFS_STATE_RECLAIM_NOGRACE flag to force
state reclaim using standard OPEN and LOCK.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
