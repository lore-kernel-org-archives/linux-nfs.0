Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f118.google.com ([209.85.221.118]:36549 "EHLO
	mail-qy0-f118.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbZDICVC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2009 22:21:02 -0400
Received: by qyk16 with SMTP id 16so863142qyk.33
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2009 19:21:01 -0700 (PDT)
Message-ID: <49dd5b8c.85c2f10a.5f05.1c22@mx.google.com>
Date: Wed, 08 Apr 2009 22:20:13 -0400
To: David Howells <dhowells@redhat.com>
From: Tom Talpey <tmtalpey@gmail.com>
Subject: NFS fscache offline mode?
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Does the new NFS fscache support offline mode? That is, can
the client continue to serve cached files even in the absence
of any service communication at all?

I see that the fscache itself can do this, but it also seems to
require the netfs (NFS) to invoke it with "pinning" operations.
I don't see any pinning calls, or options to request the behavior
in the NFS code currently.

I actually have one other semi-related question. In fscache-index.c,
the fscache generates keys to match servers by computing an
{NFS version, transport protocol, port, IP address} tuple. Have
you given thought to how this might work with NFSv4.1 sessions?
With 4.1, the session allows trunking and reconnection to multiple
server addresses. It appears the cache basically won't hit on
such configurations. I think the nfs_server_key structure will
require more thought for 4.1.

Tom.

