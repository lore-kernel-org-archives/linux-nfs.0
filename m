Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654Ab2LTNmp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2012 08:42:45 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91196C0B0@SACEXCMBX04-PRD.hq.netapp.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA91196C0B0@SACEXCMBX04-PRD.hq.netapp.com> <6078496.RFsWrNWv86@localhost> <4FA345DA4F4AE44899BD2B03EEEC2FA91196AB48@SACEXCMBX04-PRD.hq.netapp.com> <2073442.2DDQICUc2y@localhost>
To: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>
Cc: dhowells@redhat.com,
        =?us-ascii?Q?=3D=3Futf-7=3FB=3FUGF3ZStBVUktIFNpa2?=
	 =?us-ascii?Q?9yYQ=3D=3D=3F=3D?= <pawel.sikora@agmk.net>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [3.6.11] NFS: Cache request denied due to non-unique superblock keys.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Date: Thu, 20 Dec 2012 13:42:37 +0000
Message-ID: <30146.1356010957@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> From e8ed657ba5edc8c9339e00ab2fd235ab1dd94cd5 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Wed, 19 Dec 2012 16:56:28 -0500
> Subject: [PATCH] NFS: Kill fscache warnings when mounting without -ofsc
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
> The fscache code will currently bleat a "non-unique superblock keys"
> warning even if the user is mounting without the 'fsc' option.
> There should be no reason to even initialise the superblock cache cookie
> unless we're planning on using fscache for something, so ensure that
> we check for the NFS_OPTION_FSCACHE flag before calling into the
> fscache code.
> 
> Reported-by: Paweł Sikora <pawel.sikora@agmk.net>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: David Howells <dhowells@redhat.com>

Acked-by: David Howells <dhowells@redhat.com>
