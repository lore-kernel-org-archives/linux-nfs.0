Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-2.hut.fi ([130.233.228.92]:41946 "EHLO smtp-2.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755386Ab0FQOm2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 10:42:28 -0400
Date: Thu, 17 Jun 2010 17:41:32 +0300 (EEST)
From: Timo Aaltonen <timo.aaltonen@aalto.fi>
To: Fred Isaman <iisaman@netapp.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/1] fix delay on mount and umount
In-Reply-To: <1276693350-1780-1-git-send-email-iisaman@netapp.com>
Message-ID: <alpine.DEB.2.00.1006171737230.24360@deckard.hut.fi>
References: <1276693350-1780-1-git-send-email-iisaman@netapp.com>
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 16 Jun 2010, Fred Isaman wrote:

> This fixes the delay issues we've been having.

What kind of delays are we talking about and since which kernel version? 
With 2.6.32 it takes several minutes to umount a 100 NFSv4 shares. 
Mounting them is much faster but not instant.

Probably will end up using the automounter anyway, but it's nice to know 
if this fixes the issue.

-- 
Timo Aaltonen
Systems Specialist
Aalto University IT
