Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51333 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751849Ab2AJR6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 12:58:07 -0500
Message-ID: <4F0C7C2B.50109@netapp.com>
Date: Tue, 10 Jan 2012 12:58:03 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "Trond.Myklebust@netapp.com" <trond.myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 0/4] NFS: Modularize NFS v3
References: <1322758102-29260-1-git-send-email-bjschuma@netapp.com> <4F0C789C.5010508@parallels.com>
In-Reply-To: <4F0C789C.5010508@parallels.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue Jan 10 12:42:52 2012, Stanislav Kinsbursky wrote:
> Hi, Bryan.
> Are you still on progress with this stuff?

Yeah, I'm still working on this.  I'm taking a final pass over my 
patches now to see if I need to change anything else before posting 
them.  They should be ready soon.

- Bryan

> I'm wondering, because I have to reorganize RPC versions and programs code in the way to collect statistics per container. I actually have few patches already, which implements functionality similar to your new versions adding.
> And thus it would be great to know, do i need to take your work into account or not.
>


