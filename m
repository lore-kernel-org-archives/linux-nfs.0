Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport2-out.teksavvy.com ([206.248.154.182]:59890 "EHLO
	ironport2-out.teksavvy.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750898Ab3ARPsE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 10:48:04 -0500
Message-ID: <50F96EB2.3090605@teksavvy.com>
Date: Fri, 18 Jan 2013 10:48:02 -0500
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F42F85.50907@teksavvy.com> <20130114203711.GA29982@fieldses.org> <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com> <50F72F03.5070806@teksavvy.com> <50F786AF.4070107@parallels.com> <20130117130335.GD6598@fieldses.org> <50F7FB7E.2020503@parallels.com> <50F88C14.7030903@teksavvy.com> <50F8DF7E.8080107@parallels.com>
In-Reply-To: <50F8DF7E.8080107@parallels.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13-01-18 12:37 AM, Stanislav Kinsbursky wrote:
>
> You have more than one NFS mount in different network namespaces, haven't you?
>

No, I don't (knowingly) use (multiple) namespaces at all.
Usually I disable them in the kernel .config,
though it appears the currently running kernel has this:

CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_PID_NS is not set
# CONFIG_NET_NS is not set

The full .config was attached to the first post in this thread.

Cheers

