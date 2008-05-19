From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: how to parse the 64byte NFSv3 file handle
Date: Mon, 19 May 2008 07:08:38 -0400
Message-ID: <RTPCLUEXC1-PRDpAOAk000000fd@RTPMVEXC1-PRD.hq.netapp.com>
References: <483136FC.4050208@ncic.ac.cn>
 <483140C4.3010104@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>, Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25398 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755706AbYESLJC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 07:09:02 -0400
In-Reply-To: <483140C4.3010104@panasas.com>
References: <483136FC.4050208-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>
 <483140C4.3010104@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 04:56 AM 5/19/2008, Benny Halevy wrote:
>On May. 19, 2008, 11:14 +0300, xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org> wrote:
>> recently, I want to get some information (like file access patten)
>> from a trace of NFS client. The simplest way may be parse the file
>> handle to get the file ino and directory ino, but I don't know how to
>> get them from the 64 of 16 hexadecimal. Can you tell me how to parse
>> file handle to get useful information, thanks very much.
>
>That file handle contents are opaque to the client so you'd
>need to have the server's code or reverse engineer its
>structure.

Wireshark understands the format of many NFS server filehandles. You
can simply zoom-in on the filehandle in the details pane to see much of
this. Alternatively, you can look back in the trace to find the LOOKUP
or READDIR/READDIRPLUS to find the mapping between name and
filehandle.

By the way, not all filehandles are 64 bytes. That, too, is a server-specific
choice.

Tom.

