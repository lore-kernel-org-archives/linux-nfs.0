From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Linux client mount fails with Gluster NFSv3 server
Date: Tue, 1 Sep 2009 12:43:35 -0400
Message-ID: <20090901164334.GL22846@fieldses.org>
References: <4A9BD90B.4090804@gluster.com> <1251738771.5144.21.camel@heimdal.trondhjem.org> <4A9CC186.10504@gluster.com> <1251807998.18608.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39648 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249AbZIAQne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 12:43:34 -0400
In-Reply-To: <1251807998.18608.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 01, 2009 at 08:26:37AM -0400, Trond Myklebust wrote:
> On Tue, 2009-09-01 at 12:09 +0530, Shehjar Tikoo wrote:
> > I am able to view the packets just fine using wireshark Version 1.0.6.
> > It is possible that the default options for you for TCP and RPC are
> > not same as the ones below.
> > Could you please try viewing the dump with the following options set 
> > in the wireshark Protocol preferences pane.
> > 
> > Press <Ctrl> + <Shift> + p to bring up the protocol preferences
> > window.
> > 
> > First, expand the "Protocol" section header in the window that pops
> > up. Then look for "TCP" section. In the TCP section, please check the 
> > following option:
> > 
> > "Allow subdissector to reassemble TCP streams"
> > 
> > Then, search for the "RPC" section under "Protocols". For RPC, please
> > check the following option:
> > 
> > "Reassemble RPC over TCP message spanning multiple TCP segments"
> > 
> > This should make the RPC records visible properly.
> 
> I always run with those options enabled, and they were able to
> reconstruct most of the RPC records correctly, but not the reply to the
> FSINFO call.

Same here--both options set, and I don't normally have this problem.
The segments look OK, though (the sequence numbers are what you'd
expect, anyway)--if the xdr was screwed up you'd think wireshark would
still attempt to parse it.  I'm using 1.0.7 (from 1.0.7-1ubuntu1), but
too lazy to try to debug wireshark....

--b.

> Furthermore, when I looked at the binary contents, it seemed to me that
> the post-op attributes contained some fishy information, such as
> nlink==0. That alone would cause the NFS client to give up.
