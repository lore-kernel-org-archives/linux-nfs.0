Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51445 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab3HHP4o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Aug 2013 11:56:44 -0400
Date: Thu, 8 Aug 2013 11:56:43 -0400
To: Weston Andros Adamson <dros@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] nfs4.1: Initial SP4_MACH_CRED implementation
Message-ID: <20130808155643.GK5282@fieldses.org>
References: <1375823311-18457-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1375823311-18457-1-git-send-email-dros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 06, 2013 at 05:08:26PM -0400, Weston Andros Adamson wrote:
> These patches are the initial client-side SP4_MACH_CRED implementation.
> 
> Patch 1 is a repost with a few cleanups
> 
> Patch 2 adds the sp4 handler that replaces the cred on an rpc message (and
> picks the right rpc_clnt).  Note that for now, we always use the machine cred
> if supported - we could only use it if the user cred expires, but this is
> simple and spec compliant.

So anything on the spo_may_enforce_list will *always* use the machine
cred?

I wonder....  This is within the letter of the spec, but the spec also
does also give the motivation.  ("The purpose of spo_must_allow is to
allow clients to solve the following conundrum....")

I'd worry that server implementors will also stick to the letter of the
spec and allow this, but also design under the assumption that this is a
rare case.  (E.g., allow the access but trigger some extra auditing??)

I'd probably try it this way first too, as you say, it's simpler, but I
wonder whether it's really what we want to client doing all the time.

> Patch 3-5 implement SP4_MACH_CRED "features":
>   - cleanup - CLOSE and LOCKU use machine cred
>   - secinfo - SECINFO and SECINFO_NO_NAME use machine cred
>   - stateid - TEST_STATEID and FREE_STATEID use machine cred
> 
> There are three more features that I've been working on, but need to be tested
> before I post:
>   - commit - COMMIT uses machine cred
>   - write - WRITE uses machine cred, forces stable writes unless commit feature
>             is also enabled
>   - recovery - OPEN and LOCK can use machine cred - only in recovery.
> 
> The commit and write cases should be easy to test against a hacked nfsd, but
> I need to think more about how to test the recovery stuff...

Can't you just hack nfsd to allow those ops and then do a server
restart, or try Bryan's fault-injection interface if you want to test
some more exotic recovery scenario?

--b.
