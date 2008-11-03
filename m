From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 03 Nov 2008 11:59:04 -0500
Message-ID: <1225731544.6958.6.camel@heimdal.trondhjem.org>
References: <1225724721.2247.29.camel@brian-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60199 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755934AbYKCQ7K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2008 11:59:10 -0500
In-Reply-To: <1225724721.2247.29.camel@brian-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-03 at 10:05 -0500, Brian J. Murrell wrote:
> I have a system which I migrated a couple of mounts from sys
> authentication on nfs3 to gssapi on nfsv4 to overcome the 16
> supplementary groups limitation inherent in the "sys" security model.
> 
> It was working for a while but now I have "stuck" (i.e. hung) NFS
> mounts.  It seems that a mount issued from the automounter kicked all of
> this off but I cannot be sure of that.
> 
> In my process table I have a number of processes blocked in the NFSv4
> path including a mount command:
> 
> /bin/mount -t nfs4 -s -o sec=krb5i,rw,soft,intr,rsize=8192,wsize=8192 linux:/home/share /autohome/share

BTW: NFSv4 + soft == BAD BAD BAD! You will see weird behaviour, as the
client and the server will have divergent opinions on what happened
if/when an RPC call fails.

Otherwise, have you checked on the state of your rpc.gssd? It looked as
if several of those traces were waiting around RPCSEC_GSS upcalls...

Cheers
  Trond

