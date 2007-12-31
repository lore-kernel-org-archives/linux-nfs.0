From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: [NFS] read-ahead in NFS server
Date: Sun, 30 Dec 2007 20:33:45 -0800
Message-ID: <47787129.7060809@gmail.com>
References: <c70ff3ad0712250734u2f9512f8j1e04f1179a4e2616@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: saeed bishara <saeed.bishara@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36447 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbXLaEd4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 30 Dec 2007 23:33:56 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J9CLa-0002Lq-0Y
	for linux-nfs@vger.kernel.org; Mon, 31 Dec 2007 15:33:54 +1100
In-Reply-To: <c70ff3ad0712250734u2f9512f8j1e04f1179a4e2616-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My understanding is that readahead is a client concept, in the sense 
that the nfs client and ext3 are both clients.  The NFS client performs 
readahead, which is carried out as a series of 32 KB requests.  The 
exported file system client, ext3 in your case, will decide how best to 
react to these requests and perform readahead, etc as necessary.  The 
NFS server only relays the I/O requests to the underlying file system, 
although it might delay (on linux) or gather the requests for maximum 
performance.

I believe ext3 uses the standard linux readahead mechanism, so readahead 
should be occurring.  How are you determining on the server that ext3 is 
only issuing 32KB requests to the disks?  I bet that the nfs server is 
passing 32 KB requests to ext3, which in turn is issuing larger requests 
to the disks.

Another thing to do is on linux you can increase the rsize to 1 MB to 
get larger chunks out of the disks.

Dean

saeed bishara wrote:
> Hi,
> my NFS server seems not to utilize the read-ahead feature, my exported
> dir is located on ext3 fs over sata disk. the sata controller can
> issue commands up to 1MB, also I modified the read ahead under the sys
> to 1MB. but when the client do reads in 32KB chunks (rsize), I can see
> in the server side that all IOs are ~32KB. my kernel version is
> 2.6.22.7.
> does the NFS server utilizes the read-ahead feature? what should I do
> to enable it?
>
> please CC me as I'm not subscribed to this list.
> saeed
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>     http://vger.kernel.org/vger-lists.html#linux-nfs
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

