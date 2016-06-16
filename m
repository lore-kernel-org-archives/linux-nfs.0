Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:59202 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbcFPBym convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 21:54:42 -0400
Subject: Re: [PATCH 0/3] nfsd state handling fixes
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1465961286-925636-1-git-send-email-green@linuxhacker.ru>
Date: Wed, 15 Jun 2016 21:54:28 -0400
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <AAEF6AFC-06DE-46DA-A409-D69A5F8D3E3D@linuxhacker.ru>
References: <1465945026.12291.5.camel@poochiereds.net> <1465961286-925636-1-git-send-email-green@linuxhacker.ru>
To: Jeff Layton <jlayton@poochiereds.net>,
        "J . Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 14, 2016, at 11:28 PM, Oleg Drokin wrote:

> These three patches do the much discussed job of making nfsd state handling
> more robust in face of races where several opens arrive for the same file
> at the same time from the same client.
> 
> This does not yet handle a case when one of those opens gets an error
> and others don't.
> 
> Also this is undergoing testing ATM, so please only use it as a
> discussion/review piece for now.

With 24 hours in testing an no problems encountered, I guess
it's safe to declare this patchset as good to go if nobody has any
objections against it.

> 
> Oleg Drokin (3):
>  nfsd: Always lock state exclusively.
>  nfsd: Extend the mutex holding region around in nfsd4_process_open2()
>  nfsd: Make init_open_stateid() a bit more whole
> 
> fs/nfsd/nfs4state.c | 67 +++++++++++++++++++++++++++++------------------------
> fs/nfsd/state.h     |  2 +-
> 2 files changed, 38 insertions(+), 31 deletions(-)
> 
> -- 
> 2.7.4

