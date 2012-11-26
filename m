Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64932 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab2KZQBa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 11:01:30 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so8115141pbc.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 08:01:30 -0800 (PST)
Message-ID: <50B39233.3070406@gmail.com>
Date: Mon, 26 Nov 2012 21:30:51 +0530
From: "dE ." <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Slow NFS loop performance.
References: <50AF57A3.3090000@gmail.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092F876C@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092F876C@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/24/12 00:34, Myklebust, Trond wrote:
> You're using a non-default timeo=60 on a TCP connection.
>
> Why?

This's a LAN with just 2 PCs. So there're no packet drops, so there's no 
point resending requests frequently.
