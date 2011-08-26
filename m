Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:44234 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab1HZX4W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Aug 2011 19:56:22 -0400
Message-ID: <4E583292.1070707@panasas.com>
Date: Fri, 26 Aug 2011 16:56:02 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: nfsd4_open Avoid race with grace period expiration
References: <4E45C164.1070604@panasas.com> <20110826203924.GC17196@fieldses.org> <4E58119A.3090403@panasas.com> <20110826215451.GF16090@pad.fieldses.org>
In-Reply-To: <20110826215451.GF16090@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/26/2011 02:54 PM, J. Bruce Fields wrote:
> On Fri, Aug 26, 2011 at 02:35:22PM -0700, Boaz Harrosh wrote:
> 
> 
> If it's really necessary then maybe do it with printk_once().
> 
> Which clients are you worried about exactly?
> 

I'm afraid of Server bugs, actually, as demonstrated lately.

I'll summit a patch that atleast does a dprint to help
someone that tries to debug his problems.

Thanks
Boaz

