Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:50235 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053Ab2CEEqn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Mar 2012 23:46:43 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Sun, 4 Mar 2012 21:46:43 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DCD6419D8048
	for <linux-nfs@vger.kernel.org>; Sun,  4 Mar 2012 21:46:34 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q254ke4d181318
	for <linux-nfs@vger.kernel.org>; Sun, 4 Mar 2012 21:46:40 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q254kdpm016276
	for <linux-nfs@vger.kernel.org>; Sun, 4 Mar 2012 21:46:39 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q254kdEV016258
	for <linux-nfs@vger.kernel.org>; Sun, 4 Mar 2012 21:46:39 -0700
Date: Sun, 4 Mar 2012 22:46:38 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
Message-ID: <20120305044638.GA12833@us.ibm.com>
References: <4F2E620F.5090100@panasas.com>
 <20120207204401.GA31752@us.ibm.com>
 <4F511B21.1020907@RedHat.com>
 <20120302192758.GA28389@us.ibm.com>
 <4F513429.1050209@RedHat.com>
 <20120302220108.GA17119@us.ibm.com>
 <4F525741.2060404@RedHat.com>
 <1330801976.2781.19.camel@lade.trondhjem.org>
 <4F53ED3C.2020209@RedHat.com>
 <1330901196.14357.7.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1330901196.14357.7.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
> No. Please don't strip the multiple slashes either. Just leave the path
> alone after you've separated it from the devicename.
> 
> It is quite OK to normalize the path on the _client_ side (i.e.
> change //mnt to /mnt or whatever) but don't touch the server side.

As I understand, we can normalize and store it in /etc/mtab and
normalization is done by the kernel for /proc/mounts. In other words,
follow the kernel and make the /etc/mtab entries consistent with the
kernel.

In my patch, I decided to normalize at umount time when we compare the
mtab and proc file entries.

Any opinion on which one is better?

Thanks, Malahal.

