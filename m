Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:53170 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753Ab1ARP76 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 10:59:58 -0500
Subject: Re: NFS OOps  - kernel BUG at fs/nfs/nfs3xdr.c:1338
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <Chuck.Lever@oracle.com>
In-Reply-To: <1295048791.20016.15.camel@heimdal.trondhjem.org>
Date: Tue, 18 Jan 2011 10:59:14 -0500
Cc: Milan Broz <mbroz@redhat.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Message-Id: <BC9E8816-B395-44C1-ACF8-FEC4E80870C1@oracle.com>
References: <4D30D9D6.2080809@redhat.com> <1295048791.20016.15.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 14, 2011, at 6:46 PM, Trond Myklebust wrote:

> On Sat, 2011-01-15 at 00:18 +0100, Milan Broz wrote: 
>> Hi,
>> 
>> on today Linus' tree I get OOps if using nfs.
>> 
>> server (2.6.36) exports dir:
>> /dir   172.16.1.0/24(rw,async,all_squash,no_subtree_check,anonuid=500,anongid=500)
>> 
>> on client it is mounted  in fstab
>> server:/dir  /mnt/tst  nfs  rw,soft 0 0
>> 
>> and these commands OOpses it (simplified from a configure script):
>> 
>> cd /dir
>> touch x
>> install x y
>> 
>> [  105.327701] ------------[ cut here ]------------
>> [  105.327979] kernel BUG at fs/nfs/nfs3xdr.c:1338!
> 
> Chuck, why did you add those BUG_ON()s there? I know that
> nfsacl_encode() is for some unfathomable reason declared as returning an
> unsigned integer, but if you look at the actual code, you will see that
> it returns a number of negative signed error values depending on whether
> or not allocations succeeded, number of entries is valid, etc...
> 
> IOW: negative values are perfectly allowable here, and should simply
> cause the rpc call to be aborted, not an Oops.

XDR encoders no longer return an error code to the generic RPC client code.  The architectural assumption is that the heavy lifting (error checking, resource allocation, etc) is done by the upper layers, and that any problems that occur in the XDR routines are software bugs.  This seems to be the only remaining XDR code that depends on returning an error.  (I recall there may be one spot in the NFSv4 XDR code too).

We should have checked nfsacl_encode() more closely before the recent spate of XDR changes.  However, this bit of layering violation has been a thorn in our side for years.  Perhaps we can use the new xdr_stream scratch buffer to address the allocation failure issues here, and better error checking can be done in the upper layers.

Milan, I assume the install command is trying to set an ACL on an NFS file.  Can you tell us what the ACL looks like?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




