From: James Lentini <jlentini@netapp.com>
Subject: Re: [NFS] Status of NFS/RDMA in mainline kernel?
Date: Tue, 15 Jan 2008 14:56:30 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0801151450530.29575@jlentini-linux.nane.netapp.com>
References: <478D0747.1050301@charter.net> <478D0AA1.6020603@charter.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jeffrey B. Layton" <laytonjb-xwVYE8SWAR3R7s880joybQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47698 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314AbYAOT6Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 14:58:25 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JErvT-0003vr-P6
	for linux-nfs@vger.kernel.org; Wed, 16 Jan 2008 06:58:23 +1100
In-Reply-To: <478D0AA1.6020603-xwVYE8SWAR3R7s880joybQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 15 Jan 2008, Jeffrey B. Layton wrote:

> Jeffrey B. Layton wrote:
> > I haven't seen anything about NFS over RDMA lately. What's the current
> > status of this on both the server and client side?
> >   
> Sorry - I was thinking NFSv3 support, but I wouldn't mind learning
> about NFSv4 as well.
> 
> Jeff

The NFS/RDMA client will be part of 2.6.24. The code supports v2, v3, 
and v4. The easiest way to obtain the code is to download the latest 
2.6.24-rc from kernel.org. There are instructions describing how to 
install and use the code at http://nfs-rdma.sf.net.

The server has been reviewed several times on this list recently. My 
understanding is that it will be merged upstream in 2.6.25.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

