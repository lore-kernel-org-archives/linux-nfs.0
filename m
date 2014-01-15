Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314AbaAOU16 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jan 2014 15:27:58 -0500
Date: Wed, 15 Jan 2014 12:27:54 -0800
From: Zach Brown <zab@redhat.com>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org
Subject: [LSF/MM TOPIC] copy offloading
Message-ID: <20140115202754.GL8102@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Discussing copy offloading at LSF is appropriate because it can involve
so many layers of the stack:

 - high level syscall interface
 - in-kernel high level entry point for nfsd 
 - fs specific implementations (btrfs and ocfs2 cow, nfs) 
 - vfs helper for offloading block copies for ext*,xfs
 - bio offload requests for cow block devices like bcache/dm-cache
 - encoding offload bios into scsi reqs
 - processing virt guest device offload requests with host syscalls

Getting the user and in-kernel interfaces right to support all these
moving parts has proven tricky.  The more input, the better.

It's been a while since I sent out a refreshed version of the series.
That'll be remedied before LSF rolls around :). 

- z
