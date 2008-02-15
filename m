From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Performance question
Date: Fri, 15 Feb 2008 11:13:50 -0500
Message-ID: <1203092030.11333.4.camel@heimdal.trondhjem.org>
References: <90d010000802140740y3ff2706ybc169728fbafbfb4@mail.gmail.com>
	 <42996ba90802140827p533779c6o8ab404400be51fdc@mail.gmail.com>
	 <80E378BD-86F7-4009-832A-2978A6FB4600@oracle.com>
	 <90d010000802150737x2ad0739dmeaaa24dc2845e81a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	Marcelo Leal <diversos-roWltSPQdMkZWYhx5MAOMFAUjnlXr6A1@public.gmane.org>
To: Font Bella <fontbella@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:56876 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752604AbYBOQNz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2008 11:13:55 -0500
In-Reply-To: <90d010000802150737x2ad0739dmeaaa24dc2845e81a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-02-15 at 16:37 +0100, Font Bella wrote:

> Finally, try different values of rsize and wsize in your
> /etc/fstab, /etc/auto.home (if using automounts), or in general, in any mount
> command. Check from client side also with 'cat /proc/mounts'.
> Test your favourite benchmark with different rsize,wsize and look for an
> optimal value.
> 
> ALL the steps above were necessary for me to get good performance, but
> the last step was
> crucial, since I got very different performances depending on the
> value of rsize/wsize.

That very likely implies that you have problems with UDP packet loss.
Switch to TCP.

Trond

