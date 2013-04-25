Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:3991 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757064Ab3DYM74 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 08:59:56 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jiri Horky <jiri.horky@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: Kerberos security flavors not tried in SETCLIENTID_CONFIRM
 client requests
Date: Thu, 25 Apr 2013 12:59:54 +0000
Message-ID: <1366894793.4719.4.camel@leira.trondhjem.org>
References: <517923D2.2000002@gmail.com>
In-Reply-To: <517923D2.2000002@gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-04-25 at 14:38 +0200, Jiri Horky wrote:
> Hello all,
> 
> (everything described below is from a client with 3.6.11-gentoo kernel).
> 
> When I mount a filesystem that is exported as follows:
> 
> /exports 
> *(sec=krb5:krb5i:krb5p,rw,fsid=0,sync,no_subtree_check,no_root_squash,insecure,crossmnt)
> 
> without specifiying a security flavour on client, the mount will work. 
>  From the tcpdump I can tell that the client tries AUTH_UNIX and 
> AUTH_NULL flavours before succeeding with RPCSES_GSS. When I do a "ls" 
> command in the mounted directory it works fine as well - this time 
> clients uses RPCSES_GSS authentication right away.
> 
> The problems comes with "cat" command on a file, when the client calls 
> SETCLIENID with AUTH_UNIX credentials and AUTH_NULL verifier, which 
> successes but then call SETCLIENTID_CONFIRM again with just 
> AUTH_UNIX/AUTH_NULL which results in NFS4ERR_WRONGSEC. The client tries 
> to all the SETCLIENTID_CONFIRM multiple times, but it does not try 
> Kerberos authentication. The WRONGSEC error is then propagated as EIO to 
> the application.
> 
> I noticed patches from Chuck Level on 03/16/2013 which fix problems with 
> security flavours handling but I am not sure whether they are supposed 
> to fix thix particular problem as well. It would take me considerable 
> amount of time to test it so I would appreciate if you could comment on 
> that.

That's not a client problem. You have a buggy server: NFS4ERR_WRONGSEC
is not listed as a valid error for SETCLIENTID or for
SETCLIENTID_CONFIRM in either RFC3530 or RFC3530bis.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
