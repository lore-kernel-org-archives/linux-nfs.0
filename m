Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linux-iscsi.org ([67.23.28.174]:57482 "EHLO
	linux-iscsi.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbaAOXJA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jan 2014 18:09:00 -0500
Message-ID: <1389827455.5567.602.camel@haakon3.risingtidesystems.com>
Subject: Re: [LSF/MM TOPIC] copy offloading
From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
To: Zach Brown <zab@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org
Date: Wed, 15 Jan 2014 15:10:55 -0800
In-Reply-To: <20140115202754.GL8102@lenny.home.zabbo.net>
References: <20140115202754.GL8102@lenny.home.zabbo.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-01-15 at 12:27 -0800, Zach Brown wrote:
> Discussing copy offloading at LSF is appropriate because it can involve
> so many layers of the stack:
> 
>  - high level syscall interface
>  - in-kernel high level entry point for nfsd 
>  - fs specific implementations (btrfs and ocfs2 cow, nfs) 
>  - vfs helper for offloading block copies for ext*,xfs
>  - bio offload requests for cow block devices like bcache/dm-cache
>  - encoding offload bios into scsi reqs
>  - processing virt guest device offload requests with host syscalls
> 
> Getting the user and in-kernel interfaces right to support all these
> moving parts has proven tricky.  The more input, the better.
> 
> It's been a while since I sent out a refreshed version of the series.
> That'll be remedied before LSF rolls around :). 
> 

+1

Now that EXTENDED_COPY LID1 target mode logic is upstream, I'm really
eager to start utilizing it Linux host side.  ;)

--nab

