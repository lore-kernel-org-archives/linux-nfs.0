Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e36.co.us.ibm.com ([32.97.110.154]:51343 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720Ab2CBWB1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 17:01:27 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 2 Mar 2012 15:01:26 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 0E74519D804C
	for <linux-nfs@vger.kernel.org>; Fri,  2 Mar 2012 15:01:19 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q22M19P0062676
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 15:01:10 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q22M19JQ020494
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 15:01:09 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q22M18dm020472
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 15:01:08 -0700
Date: Fri, 2 Mar 2012 16:01:08 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
Message-ID: <20120302220108.GA17119@us.ibm.com>
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
 <4F2BC1C0.8070900@panasas.com>
 <20120203231623.442fefde@notabene.brown>
 <20120203142945.GA31805@us.ibm.com>
 <4F2E620F.5090100@panasas.com>
 <20120207204401.GA31752@us.ibm.com>
 <4F511B21.1020907@RedHat.com>
 <20120302192758.GA28389@us.ibm.com>
 <4F513429.1050209@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F513429.1050209@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson [SteveD@redhat.com] wrote:
> So what my patch does is "normalizes" the device name early
> on in main, so the correct name used used through the mount
> and when its written the mtab. Plus, for better or worses, 
> since the new device name will always be shorter, I just 
> reuse/rewrite the memory allocated for the argv vector.. 
> Meaning there is no allocation... 

My problem is a bit different.

"mount -t nfs4 server:export /mnt" works but umount fails.

Notice that there is no '/' in the path!

Normalizing or just stripping leading '/'s early won't help with the
above problem and since there is already a hack to strip the
__trailing__ '/' that kernel adds to /proc/mounts file, I just made the
existing hack it a bit better by normalizing.

Regards, Malahal.

