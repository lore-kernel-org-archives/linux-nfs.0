From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: are multiple FSIDs supported?
Date: Fri, 23 Oct 2009 15:00:53 -0400
Message-ID: <20091023190053.GB32155@fieldses.org>
References: <babafd2f0910231132n464da0crc2a5cc0427af9a40@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ben DJ <bendj095124367913213465@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33499 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752577AbZJWS7k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2009 14:59:40 -0400
In-Reply-To: <babafd2f0910231132n464da0crc2a5cc0427af9a40-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 23, 2009 at 11:32:44AM -0700, Ben DJ wrote:
> Hello,
> 
> I'm building an NFSv4 FileServer.  My goal is to service multiple
> machines on a LAN, each with their own, isolated namespace (I'm not
> sure that's the right terminology).
> 
> Reading the man page it seems that only ONE fsid=0 export is allowed
> per server.  And that subdirectories of that root CAN be exported, but
> always under the same/one root.
> 
> That doesn't seem like "good isolation" to me.
> 
> My goal would be to export, for example
> 
>  /nfs1 & it's subdirs ONLY to LAN box1
>  /nfs2 & it's subdirs ONLY to LAN box2
>  etc

Multiple export namespaces aren't currently supported.

I'd like to some day, though I'd prefer to vary the namespace based on
server ip address instead of by client ip address.

But for now I'd think just something like:

	/nfs	*(ro,fsid=0,...)
	/nfs/1	box1(rw,nohide,crossmnt)
	/nfs/2	box2(rw,nohide,crossmnt)

should server your purposes.  box1 will still be able to see that a
directory named /nfs/2 exists, but it shouldn't be able to descend into
it.  (And vice-versa for box2 and /nfs/1.)

--b.

> I've seen some mentions & discussion online of multiple-fsid's, where
> /nfs1 would be exported as a root under fsid=0, /nfs2 under fsid=1,
> etc.
> 
> But this approach doesn't look like its currently supported or
> recommended.  Even if it was I haven't found anything that says how a
> nfsv4 client would ADDRESS the specific fsid's.  Something in the
> mount's URI I guess.
> 
> I know I might still be stuck in NFSv3 thinking about this, and NFSv4
> subdirs might be isolated "well enough".
> 
> BenDJ
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
