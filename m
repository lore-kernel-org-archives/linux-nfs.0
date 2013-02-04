Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f178.google.com ([209.85.128.178]:43341 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab3BDT3t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 14:29:49 -0500
Received: by mail-ve0-f178.google.com with SMTP id db10so5040188veb.23
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 11:29:48 -0800 (PST)
Date: Mon, 4 Feb 2013 11:29:44 -0800
From: Tejun Heo <tj@kernel.org>
To: bfields <bfields@fieldses.org>
Cc: majianpeng <majianpeng@gmail.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd: Fix memleak.
Message-ID: <20130204192905.GY27963@mtj.dyndns.org>
References: <201301291315585633212@gmail.com>
 <20130129222926.GA6219@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130129222926.GA6219@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Tue, Jan 29, 2013 at 05:29:26PM -0500, bfields wrote:
> Tejun, maybe this could be added to your series?
> 
> (Or should I just take it without the idr_remove_all()?)

There are gonna be other related nfs changes anyway, so I think it
would be better to just route it through the usual nfs channel.  We
can deal with conflicts / conversion later.

Thanks.

-- 
tejun
