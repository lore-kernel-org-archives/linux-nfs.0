Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606Ab1CNRXP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2011 13:23:15 -0400
Message-ID: <4D7E4EFF.9060302@RedHat.com>
Date: Mon, 14 Mar 2011 13:23:11 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Dax Kelson <dkelson@gurulabs.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: When did NFSv4 behavior change occur?
References: <1300120256.3600.19.camel@mentorng>
In-Reply-To: <1300120256.3600.19.camel@mentorng>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 03/14/2011 12:30 PM, Dax Kelson wrote:
> In a quest to update our documentation, could someone please answer this
> question?
> 
> What kernel version did the change occur where all the entries
> in /etc/exports are shared as v4 (in addition to v2 and v3) as well as
> the automatic psuedo-root creation if fsid=0 not exist?
kernel-2.6.32.

> 
> Or maybe it was a combo of kernel version and nfs-utils version??
nfs-utils-1.2.2

steved.

> 
> Dax Kelson
> Guru Labs
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
