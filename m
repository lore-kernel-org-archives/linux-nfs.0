From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: how to parse the 64byte NFSv3 file handle
Date: Mon, 19 May 2008 10:28:12 -0400
Message-ID: <1211207292.11932.3.camel@localhost>
References: <483136FC.4050208@ncic.ac.cn> <483140C4.3010104@panasas.com>
	 <RTPCLUEXC1-PRDpAOAk000000fd@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>,
	Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:38648 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757196AbYESO2X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 10:28:23 -0400
In-Reply-To: <RTPCLUEXC1-PRDpAOAk000000fd-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-05-19 at 07:08 -0400, Talpey, Thomas wrote:
> At 04:56 AM 5/19/2008, Benny Halevy wrote:
> >On May. 19, 2008, 11:14 +0300, xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org> wrote:
> >> recently, I want to get some information (like file access patten)
> >> from a trace of NFS client. The simplest way may be parse the file
> >> handle to get the file ino and directory ino, but I don't know how to
> >> get them from the 64 of 16 hexadecimal. Can you tell me how to parse
> >> file handle to get useful information, thanks very much.
> >
> >That file handle contents are opaque to the client so you'd
> >need to have the server's code or reverse engineer its
> >structure.
> 
> Wireshark understands the format of many NFS server filehandles. You
> can simply zoom-in on the filehandle in the details pane to see much of
> this. Alternatively, you can look back in the trace to find the LOOKUP
> or READDIR/READDIRPLUS to find the mapping between name and
> filehandle.
> 
> By the way, not all filehandles are 64 bytes. That, too, is a server-specific
> choice.

...and in Linux it is actually a filesystem-specific choice.

Furthermore, since not all Linux filesystems have permanently stored
inode numbers, many filehandle types don't encode an inode number.

Finally, if you turn off subtree checking (as indeed you should), then
the filehandle doesn't contain a directory inode number.

In other words, parsing filehandles to obtain inode numbers from Linux
servers is not a task that can be easily automated...

Trond

