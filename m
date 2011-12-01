Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61798 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527Ab1LARHX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 12:07:23 -0500
Received: by yenl6 with SMTP id l6so1883256yen.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2011 09:07:22 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 1 Dec 2011 19:07:22 +0200
Message-ID: <CAA-yEOJ+5NssoCOAXzeCNOCkbbACn0qHrj-BtmMRYwxZFDZgxg@mail.gmail.com>
Subject: NFS - lock failover
From: Pavel A <free.lan.c2.718r@gmail.com>
To: linux-nfs@vger.kernel.org, wcheng@redhat.com, neilb@suse.de,
        jlayton@redhat.com, frankvm@frankvm.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi everyone!

I was trying not to create new topics, but it seems that posting to an
old one doesn't bring it up. Here is the original topic I'm referring
to: http://comments.gmane.org/gmane.linux.nfs/13108

I'm building an A/A cluster using NFS v3 and local file systems, and
looking for
efficient ways for failover (for now I have to restart nfs-kernel-server on
Takeover node to be able to initiate grace period), so the discussed solutions
are very interesting to me.

Now (4 years after) in current nfs-utils packages (v. 1.2.2-4 and later) I can
see that the ability to release locks was really implemented and is
working well
(I mean interfaces /proc/fs/nfsd/unlock_ip and
/proc/fs/nfsd/unlock_filesystem),
but how about reacquiring locks on the node, share migrates to? - I've been
going through various mailing lists and found a lot of discussions on the topic
(also dated mainly 2007), but don't seem to find any rpc-based mechanism or
interface like /proc/fs/nfsd/nlm_set_grace to do that, was it ever made?

Any clarification would be really nice. Thank you!
