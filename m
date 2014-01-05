Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:57162 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbaAEUTS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jan 2014 15:19:18 -0500
Received: by mail-ig0-f174.google.com with SMTP id hk11so5522685igb.1
        for <linux-nfs@vger.kernel.org>; Sun, 05 Jan 2014 12:19:17 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 4/4] SUNRPC: Add tracepoint for socket errors
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140105195407.GA22918@fieldses.org>
Date: Sun, 5 Jan 2014 15:19:16 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>,
        Lever Charles Edward <chuck.lever@oracle.com>,
        Gareth Williams <gareth@garethwilliams.me.uk>
Message-Id: <75900891-2527-458E-9DD2-904A681B012E@primarydata.com>
References: <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com> <1388518781-33571-1-git-send-email-trond.myklebust@primarydata.com> <1388518781-33571-2-git-send-email-trond.myklebust@primarydata.com> <1388518781-33571-3-git-send-email-trond.myklebust@primarydata.com> <1388518781-33571-4-git-send-email-trond.myklebust@primarydata.com> <20140105195407.GA22918@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 5, 2014, at 14:54, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Tue, Dec 31, 2013 at 02:39:41PM -0500, Trond Myklebust wrote:
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> include/trace/events/sunrpc.h | 1 +
>> net/sunrpc/xprtsock.c         | 1 +
>> 2 files changed, 2 insertions(+)
> 
> ACK to all these from me.  I'm assuming they'll go in through your tree
> for 3.14.

I’m queuing them up for that, yes.

Cheers
  Trond