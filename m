Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248Ab1HHAuP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Aug 2011 20:50:15 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <20031.12991.915221.116757@regina.usersys.redhat.com>
Date: Mon, 8 Aug 2011 10:50:07 +1000
From: Max Matveev <makc@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH v2] Update nfs(5) manpage - timeo for NFS/TCP
In-Reply-To: <703F70DB-E49F-47A0-B101-946147152F8B@oracle.com>
References: <20110805021903.C84608198734@regina.usersys.redhat.com>
	<20110805124015.GA16926@merit.edu>
	<703F70DB-E49F-47A0-B101-946147152F8B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 5 Aug 2011 16:33:41 -0400, Chuck Lever wrote:

 > I thought that to_maxval was 60 seconds (600 deciseconds).  Once
 > the effective timeo has increased to 60 seconds, it doesn't
 > increase further.  Thus, if the default timeo setting is already 60
 > seconds, you get effectively a fixed 60 second timeout, right?

In trond's tree - include/linux/nfs_fs.h

#define NFS_MAX_TCP_TIMEOUT	(600*HZ)

max


