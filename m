Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:40962 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350Ab2ELOkV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 May 2012 10:40:21 -0400
Message-ID: <4FAE7650.2090201@parallels.com>
Date: Sat, 12 May 2012 18:40:16 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] NFSd laundromat containerization
References: <4FAD1934.8070908@parallels.com> <20120511135306.GA12795@fieldses.org> <4FAE2659.4090107@parallels.com> <20120512141653.GA19757@fieldses.org>
In-Reply-To: <20120512141653.GA19757@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12.05.2012 18:16, bfields@fieldses.org wrote:
> Actually, ownerstr and lockowner_ino should also both be per-container.
>
> So it's only file and del_recall_lru that should be global.  (And
> del_recall_lru might work either way, actually.)

Thanks. Will do so.
BTW, have you noticed the patch, which protects service lists during per-net 
shutdown?
Title: "SUNRPC: protect service sockets lists during per-net shutdown"

-- 
Best regards,
Stanislav Kinsbursky
