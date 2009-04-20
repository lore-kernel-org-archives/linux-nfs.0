From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Will NFS client use write-back caching?
Date: Mon, 20 Apr 2009 08:21:52 -0400
Message-ID: <1240230112.8073.4.camel@heimdal.trondhjem.org>
References: <b66ddc900904200256yb62b5f7x43ebf70c0ebcdefd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: howard chen <howachen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36444 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754474AbZDTM5Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Apr 2009 08:57:25 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Lvt3q-0006pF-AW
	for linux-nfs@vger.kernel.org; Mon, 20 Apr 2009 22:57:22 +1000
In-Reply-To: <b66ddc900904200256yb62b5f7x43ebf70c0ebcdefd-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-04-20 at 17:56 +0800, howard chen wrote:
> Hello,
> 
> My client is running ext3, which default has 5 seconds of write-back
> caching, e.g.
> 
>  cat /proc/sys/vm/dirty_writeback_centisecs
> 499
> 
> Now, if this client connect to a NFS (v3), and write data to the NFS,
> will write-back caching used?

Yes. However it will always flush out data on close() in order to ensure
that other clients see the data (see
http://nfs.sourceforge.net/#faq_a8 ).

Trond


------------------------------------------------------------------------------
Stay on top of everything new and different, both inside and 
around Java (TM) technology - register by April 22, and save
$200 on the JavaOne (SM) conference, June 2-5, 2009, San Francisco.
300 plus technical and hands-on sessions. Register today. 
Use priority code J9JMT32. http://p.sf.net/sfu/p
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

