Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065Ab1KJOu2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 09:50:28 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: NFS v4 client blocks when using UDP protocol
Date: Thu, 10 Nov 2011 06:50:23 -0800
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C0FC7AD@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <4EBB8716.7040109@cn.fujitsu.com>
References: <4EBB8716.7040109@cn.fujitsu.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "fanchaoting" <fanchaoting@cn.fujitsu.com>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: fanchaoting [mailto:fanchaoting@cn.fujitsu.com]
> Sent: Thursday, November 10, 2011 3:11 AM
> To: linux-nfs@vger.kernel.org; Myklebust, Trond
> Subject: NFS v4 client blocks when using UDP protocol
> 
> hi,
> 	1. When I use nfs i  find "NFS v4 client blocks when using UDP
> protocol".

UDP is not a supported protocol for NFSv4. It is explicitly banned in
the NFS spec (RFC3530).

> 	2. when i use RHEL6.1GA i didn't find this problem , but when  i
use
> RHEL6.2Beta i find this problem.
> 	3. Can you tell me which  patch causes this problem ?

None of them. UDP is not a supported configuration.

Trond

