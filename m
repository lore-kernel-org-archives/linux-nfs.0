Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13483 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754677Ab3HGSOS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Aug 2013 14:14:18 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/5] nfs4.1: Initial SP4_MACH_CRED implementation
Date: Wed, 7 Aug 2013 18:14:16 +0000
Message-ID: <6A6290EE-02C8-434A-8EED-EF1AC05C63CE@netapp.com>
References: <1375823311-18457-1-git-send-email-dros@netapp.com>
In-Reply-To: <1375823311-18457-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've decided to change a few things since posting this, so unless someone is in the middle of reviewing, please wait for the new patchset.

Thanks!

-dros

On Aug 6, 2013, at 5:08 PM, Weston Andros Adamson <dros@netapp.com> wrote:

> These patches are the initial client-side SP4_MACH_CRED implementation.
> 
> Patch 1 is a repost with a few cleanups
> 
> Patch 2 adds the sp4 handler that replaces the cred on an rpc message (and
> picks the right rpc_clnt).  Note that for now, we always use the machine cred
> if supported - we could only use it if the user cred expires, but this is
> simple and spec compliant.
> 
> Patch 3-5 implement SP4_MACH_CRED "features":
>  - cleanup - CLOSE and LOCKU use machine cred
>  - secinfo - SECINFO and SECINFO_NO_NAME use machine cred
>  - stateid - TEST_STATEID and FREE_STATEID use machine cred
> 
> There are three more features that I've been working on, but need to be tested
> before I post:
>  - commit - COMMIT uses machine cred
>  - write - WRITE uses machine cred, forces stable writes unless commit feature
>            is also enabled
>  - recovery - OPEN and LOCK can use machine cred - only in recovery.
> 
> The commit and write cases should be easy to test against a hacked nfsd, but
> I need to think more about how to test the recovery stuff...
> 
> -dros
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

