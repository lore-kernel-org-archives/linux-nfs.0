Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:33762 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbbC0Oug convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 10:50:36 -0400
Received: by qgfa8 with SMTP id a8so128239261qgf.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 07:50:36 -0700 (PDT)
Date: Fri, 27 Mar 2015 10:50:29 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150327105029.615354f3@tlielax.poochiereds.net>
In-Reply-To: <20150327104135.GA15651@lst.de>
References: <20150303221033.GB19439@fieldses.org>
	<20150327104135.GA15651@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 27 Mar 2015 11:41:35 +0100
Christoph Hellwig <hch@lst.de> wrote:

> FYI, I small update on tracking down the recall issue:  this seems to
> be very much something in the callback channel on the server.  When tracing
> the client all the recalls it gets they are handled fine, but we do get
> error back in the layout recall ->done handler, which most of the time
> but not always are local Linux errnos and not nfs error numbers, indicating
> something went wrong, probably in the RPC code.

Taking a quick look, the ->done routines look a little suspicious to me
anyway. AFAICT, the pc_decode routines for the callbacks always return
a Linux errno, not a nfsstat4, and that's what should end up in
tk_status.
