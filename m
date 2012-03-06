Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e38.co.us.ibm.com ([32.97.110.159]:60949 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758099Ab2CFC0J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 21:26:09 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 5 Mar 2012 19:26:09 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id D8DAA19D8048
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 19:25:02 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q262P7Nh116212
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 19:25:07 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q262P6T2000424
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 19:25:06 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q262P6Xi000402
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 19:25:06 -0700
Date: Mon, 5 Mar 2012 20:25:05 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] umount.nfs: normalize path names during umounts.
Message-ID: <20120306022505.GA32281@us.ibm.com>
References: <1330976165-19849-1-git-send-email-steved@redhat.com>
 <1330976165-19849-2-git-send-email-steved@redhat.com>
 <20120305212015.GA21904@us.ibm.com>
 <4F5559EA.7010206@RedHat.com>
 <1330993903.5407.3.camel@lade.trondhjem.org>
 <4F556007.2030603@RedHat.com>
 <1330995896.5407.8.camel@lade.trondhjem.org>
 <4F5569C5.1000100@RedHat.com>
 <20120306015230.GA4513@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120306015230.GA4513@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees [rees@umich.edu] wrote:
> I don't understand the backward compatibility issue.  Are there times when
> you have a mount, and it's in /etc/mtab, but not in /proc/mounts?  I don't
> see how that's possible.

No, but that is what NFS umount thinks due to slight differences in
those two files. Happens only in NFSv4 world. 

