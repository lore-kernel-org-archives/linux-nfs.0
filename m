Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0117.hostedemail.com ([216.40.44.117]:56649 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752073AbcF3UHb convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2016 16:07:31 -0400
Date: Thu, 30 Jun 2016 16:07:26 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
        "Linux Network Devel Mailing List" <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "Andrew Morton" <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port
 (left over from xs_bind() ))
Message-ID: <20160630160726.304a3d14@gandalf.local.home>
In-Reply-To: <72EF2259-3A78-4FE3-8E0E-B3090FDFF14F@primarydata.com>
References: <20160630085950.61e5c7e0@gandalf.local.home>
	<C44AFFBB-EF40-4B22-8B45-7817EB7276E3@primarydata.com>
	<20160630112341.5ab5a821@gandalf.local.home>
	<72EF2259-3A78-4FE3-8E0E-B3090FDFF14F@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 30 Jun 2016 18:30:42 +0000
Trond Myklebust <trondmy@primarydata.com> wrote:


> Wait. So the NFS mount is still active, it’s just that the socket
> disconnected due to no traffic? That should be OK. Granted that the
> port can’t be reused by another process, but you really don’t want
> that: what if there are no other ports available and you start
> writing to a file on the NFS partition?

What would cause the port to be connected to a socket again? I copied a
large file to the nfs mount, and the hidden port is still there?

Remember, this wasn't always the case, the hidden port is a recent
issue.

I ran wireshark on this and it appears to create two ports for NFS. One
of them is canceled by the client (sends a FIN/ACK) and this port is
what lays around never to be used again, and uses the other port for
all connections after that.

When I unmount the NFS directory, the port is finally freed (but has no
socket attached to it). What is the purpose of keeping this port around?

I can reproduce this by having the client unmount and remount the
directory.

-- Steve
