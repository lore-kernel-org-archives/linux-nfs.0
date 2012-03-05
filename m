Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e37.co.us.ibm.com ([32.97.110.158]:52317 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932379Ab2CEOrv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 09:47:51 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 5 Mar 2012 07:47:51 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6A97F19D804A
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 07:47:43 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25ElmwJ120052
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 07:47:48 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25ElikX012705
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 07:47:44 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q25ElirD012687
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 07:47:44 -0700
Date: Mon, 5 Mar 2012 08:47:43 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
Message-ID: <20120305144743.GA31639@us.ibm.com>
References: <4F513429.1050209@RedHat.com>
 <20120302220108.GA17119@us.ibm.com>
 <4F525741.2060404@RedHat.com>
 <1330801976.2781.19.camel@lade.trondhjem.org>
 <4F53ED3C.2020209@RedHat.com>
 <4F53F39E.9050802@RedHat.com>
 <1330903600.14357.10.camel@lade.trondhjem.org>
 <4F5402E4.4030506@RedHat.com>
 <1330913047.14357.19.camel@lade.trondhjem.org>
 <4F54A9BD.4020702@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F54A9BD.4020702@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson [SteveD@redhat.com] wrote:
> 
> > Which is why I'm asking you if you can't copy from /proc/mounts. Distros
> > which already have a symlink betweek /etc/mtab and /proc/mounts don't
> > have any of these problems...
> > 
> Personally I think it simpler to just normalize the paths before 
> writing it to the mtab verses open up and searching /proc/mounts
> esp on client where there is large amount of mounts...  

We always open up and search /proc/mounts today for the matching
mountpoint to know the exact version of nfs, right? The umount time
normalization is going to cost us? Or you proposing a patch that is
going to avoid opening up /proc/mounts altogether?

Regards, Malahal.

