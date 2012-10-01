Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:39480 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab2JALvp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 07:51:45 -0400
Received: by yenm12 with SMTP id m12so1356415yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2012 04:51:45 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com, steved@redhat.com,
        skinsbursky@parallels.com
Subject: [PATCH 0/2] nfsd: add a usermodehelper upcall for client id tracking
Date: Mon,  1 Oct 2012 07:51:36 -0400
Message-Id: <1349092298-23872-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A few months ago I did some patches to add an upcall to replace the
legacy clientid tracking scheme in nfsd. At the time, several people
including Boaz and Steve expressed that they would prefer an upcall that
used call_usermodehelper instead of requiring a running daemon.

While I'm loath to add yet another upcall to the kernel, I must admit
that they have a good point. Yet another running daemon for something as
infrequently called as this is less than ideal. The idiot-proofness of a
usermodehelper upcall is hard to beat for the "just works" factor.

This patchset adds a new set of client tracking ops to the kernel that
use call_usermodehelper to exec a program in userland to do its bidding.
I'll also be posting a set of nfs-utils patches soon to add the callout
program for this.

This seems to work as expected and is fairly simple. There are a couple
of lingering issues.

- Do we need to switch to a different mount namespace somehow based on
  the net namespace? Eventually we want to allow nfsd to run in a
  container. At some point we'll need a mechanism to ensure that the
  upcall runs within the correct container. Stanislav, I'd appreciate
  your input here...

- What about nfsdcld? I don't believe any distros have deployed it yet,
  and there aren't a lot of compelling reasons to stick with it if this
  patchset seems reasonable. I suggest we plan to deprecate it in a couple
  of releases unless there are objections.

Unless anyone sees major problems with this approach, I think these
patches are reasonable for 3.7.

Jeff Layton (2):
  nfsd: add a usermodehelper upcall for NFSv4 client ID tracking
  nfsd: change algorithm for selecting the client_tracking_ops

 fs/nfsd/nfs4recover.c | 174 +++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 164 insertions(+), 10 deletions(-)

-- 
1.7.11.4

