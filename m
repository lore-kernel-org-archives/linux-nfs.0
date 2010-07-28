Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48848 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755837Ab0G1RPg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jul 2010 13:15:36 -0400
Date: Wed, 28 Jul 2010 13:14:29 -0400
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: =?utf-8?B?Si5BLiDvv70=?= <jamagallon@ono.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: Questions and problems with NFS4
Message-ID: <20100728171429.GA19362@fieldses.org>
References: <20100728004611.00c46b13@werewolf.home>
 <4C4F95BC.3060200@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C4F95BC.3060200@cn.fujitsu.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 28, 2010 at 10:28:12AM +0800, Bian Naimeng wrote:
>     As i see, there's no way to disabe nlockmgr, it's start by lockd,
>     and lockd will be up when we start nfsd. It's always work until the
>     last nfsd thread stop.

Some day we should probably modify the server to turn off lockd in the
v4-only case.  For now we don't do that.

It should be fine to firewall off lockd if you only care about NFSv4.

--b.
