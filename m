Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:15472 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054Ab3CTXsu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 19:48:50 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christopher T Vogan <cvogan@us.ibm.com>, Neil Brown <neilb@suse.de>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: What is NFSv4 READDIR doesn't return a filehandle....
Date: Wed, 20 Mar 2013 23:48:48 +0000
Message-ID: <1363823327.4790.78.camel@leira.trondhjem.org>
References: <OF5A466E86.6A319FE3-ON87257B34.007C6188-86257B34.007C87C8@us.ibm.com>
In-Reply-To: <OF5A466E86.6A319FE3-ON87257B34.007C6188-86257B34.007C87C8@us.ibm.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding back in the Ccs...

On Wed, 2013-03-20 at 17:40 -0500, Christopher T Vogan wrote:

> Trond Myklebust:
> ================
> > > A customer has come across a server which does not return the 
> filehandle
> > > information (is that allowed?).
> > 
> > The filehandle attribute is a mandatory attribute according to RFC3530, 
> so I believe that the answer is "no".
> 
> Mandatory is described in RFS 3530 as that the server must return the 
> attribute
> on a GETATTR.  (Section 5, page 36).  There is nothing saying that it is
> mandatory to return on a READDIR.  Our server will return the filehandle
> on a LOOKUP/GETATTR every time.

Section 5.5 lists the filehandle as being REQUIRED, and "primarily for
readdir requests". What's the point of listing an attribute as REQUIRED,
but not for the primary (read "only!") operation where it is useful?

There is an exception allowed: if the object is a referral, then you can
return NFS4ERR_MOVED in the rdattr_error (which is also a REQUIRED
attribute that only applies to READDIR) if the client requests it.
Otherwise, you return NFS4ERR_MOVED in the READDIR result...

IOW: I strongly disagree with your argument, and repeat that your server
is broken as far as the protocol goes...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
