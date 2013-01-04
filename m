Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:63612 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754734Ab3ADOPk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 09:15:40 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Mario Bachmann <mario.bachmann@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Fix regression on NFS in mainline kernel
Date: Fri, 4 Jan 2013 14:15:30 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91198A4B4@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net>
	 <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20120419093025.GA2916@zeus> <20120419134847.GC2916@zeus>
	 <1334856549.21419.48.camel@lade.trondhjem.org>
	 <20120419204638.GB22948@zeus> <loom.20130104T105915-661@post.gmane.org>
In-Reply-To: <loom.20130104T105915-661@post.gmane.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-01-04 at 10:05 +-0000, Mario Bachmann wrote:
+AD4- Luis Henriques +ADw-luis.henriques+AEA-...+AD4- writes:
+AD4- 
+AD4- +AD4- 
+AD4- +AD4- On Thu, Apr 19, 2012 at 05:29:09PM +-0000, Myklebust, Trond wrote:
+AD4- +AD4- +AD4- On Thu, 2012-04-19 at 14:48 +-0100, Luis Henriques wrote:
+AD4- +AD4- +AD4- +AD4- On Thu, Apr 19, 2012 at 10:30:25AM +-0100, Luis Henriques wrote:
+AD4- +AD4- +AD4- +AD4- +AD4- On Wed, Apr 18, 2012 at 01:36:52PM -0400, Trond Myklebust wrote:
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4- The first patch addresses the Oops.
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4- The second will hopefully address the looping.
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4- Trond Myklebust (2):
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4-   NFSv4: Ensure that the LOCK code sets exception-+AD4-inode
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4-   NFSv4: Ensure that we check lock exclusive/shared type against open
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4-     modes
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4-  fs/nfs/nfs4proc.c +AHw-   23 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+---
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4-  1 files changed, 21 insertions(+-), 2 deletions(-)
+AD4- I use kernel 3.7.1 from kernel.org which has the patches included, 
+AD4- which should fix the problems (I checked the source code). But:
+AD4- I get +ACI-NFS: nfs4+AF8-reclaim+AF8-open+AF8-state: Lock reclaim failed+ACEAIg- on the 
+AD4- client, which mounts home over nfs4. 
+AD4- I get senseless network traffic (50MB/s on my gigabit network). 
+AD4- Finally I get Kernel Ops on the Server sometimes. 

Lock reclaiming is not guaranteed to succeed+ADs- it all depends on why the
lock was lost in the first place. Did the server restart, or did a
network partition occur? Was some other process able to take that lock
(or even delete the file, doh+ACE-), before your client could reclaim it?

That said, if the server is Oopsing, then you have a broken server. I'd
suggest posting that Oops to this list first.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
