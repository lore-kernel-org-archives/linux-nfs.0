From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Wed, 06 Feb 2008 10:00:21 -0500
Message-ID: <1202310021.12647.6.camel@heimdal.trondhjem.org>
References: <20080205090132.GA8286@stro.at>
	 <1202248931.12271.18.camel@heimdal.trondhjem.org>
	 <003301c86888$ed735a20$0301a8c0@MURTLE>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
To: Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11934 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbYBFPDT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 10:03:19 -0500
In-Reply-To: <003301c86888$ed735a20$0301a8c0@MURTLE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-06 at 19:24 +1300, Andrew Dixie wrote:
> > The fact that the delegreturn call appears to have hit xprt_timer is
> > interesting. Under normal circumstances, timeouts should never occur
> > under NFSv4. Could you tell us what mount options you're using here?
> >
> > Also please could you confirm for us that the server is still up and
> > responding to requests from other clients.
> 
> The mount options were defaults:
> i.e. mount -t nfs4 server:/mnt /mnt
> sshd has died. I will confrim exactly what is in /proc/mounts when I get 
> physical access.
> 
> The server is still up serving active nfsv3 clients. I mounted nfsv4 on 
> another client and that worked too.

Thanks. My other questions are:

  What is rpciod doing while the machine hangs?
  Does 'netstat -t' show an active tcp connection to the server?
  Does tcpdump show any traffic going on the wire?
  What server are you running against? From the error messages below, I
see it is a Linux machine, but which kernel is it running?

> The following appears in the server logs:
> Feb  4 08:28:01 devfile kernel: NFSD: setclientid: string in use by 
> client(clientid 47945499/00001c88)
> Feb  4 08:34:18 devfile kernel: NFSD: setclientid: string in use by 
> client(clientid 47945499/00001c8d)
> Feb  4 08:38:02 devfile kernel: NFSD: setclientid: string in use by 
> client(clientid 47945499/00001c8f)
> Feb  4 10:01:02 devfile kernel: NFSD: setclientid: string in use by 
> client(clientid 47a627bd/00000002)
> Feb  4 10:07:37 devfile kernel: NFSD: setclientid: string in use by 
> client(clientid 47a627bd/00000005)
> Feb  4 10:17:02 devfile kernel: NFSD: setclientid: string in use by 
> client(clientid 47a627bd/0000019e)
> Feb  5 07:59:58 devfile kernel: NFSD: setclientid: string in use by 
> client(clientid 47a627bd/000003f2)
> Feb  5 08:01:02 devfile kernel: NFSD: setclientid: string in use by 
> client(clientid 47a627bd/000003f3)
> 
> These are not close to the times that it hung.

Yep. The above is entirely expected, and is not actually a bug. I keep
asking Bruce to remove that warning...

> Prior to Feb 4 it occurs 10 to 50 times a day (from when the client was 
> running 2.6.18 kernel)
> There is only one nfsv4 client.

OK...

Thanks
  Trond
