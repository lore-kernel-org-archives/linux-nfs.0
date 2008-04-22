From: Quentin Godfroy <godfroy-7pss2ddYZfWsyDt4atOG6g@public.gmane.org>
Subject: Re: Problem with krb5 authentification, server under a NAT
Date: Tue, 22 Apr 2008 20:03:26 +0200
Message-ID: <20080422180325.GA11675@goelette.ens.fr>
References: <20080422161908.GC11221@goelette.ens.fr> <20080422165620.GF16695@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nef2.ens.fr ([129.199.96.40]:2291 "EHLO nef2.ens.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbYDVSDl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Apr 2008 14:03:41 -0400
In-Reply-To: <20080422165620.GF16695@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 22, 2008 at 12:56:20PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 22, 2008 at 06:19:09PM +0200, Quentin Godfroy wrote:
> > Hi,
> > 
> > I have a problem with krb5 authentification and nfsv4:
> > 
> > basically the server is behind a NAT which over I do not have much control.
> > To mount exported partitions I use socat on the NAT and redirect some TCP port
> > (actually 2050 because 2049 is firewalled) to the port 2049 on the server. I
> > can successfuly mount with auth=sys,port=2050, but I am unable to mount with
> > kerberos authentification. The problem seems to lie within rpc.gssd which does
> > not care for the port setting and tries to contact the server on port 2049.
> > 
> > I suppose the same could happen with nfsv{2,3} (provided the mountd port is
> > redirected as well)
> > 
> > Is this a problem you were aware of?
> > 
> > I suppose fixing it may require a change in the callback between the kernel
> > and rpc.gssd?
> 
> What kernel are you on?  As of 2.6.24 (more specifically:
> 
> 	bf19aacecbeebccb2c3d150a8bd9416b7dba81fe "nfs: add server port
> 	to rpc_pipe info file"
> 
> the kernel does give gssd the information it needs to figure out which
> port the server is on.

Both server and client are 2.6.24.something, and rpc.gssd is from Debian's
nfs-common 1:1.1.2-2

> 
> Looks to me like gssd doesn't yet use that yet, though.  Olga, did you
> have a patch to make gssd read the "port:" line from the info file?
