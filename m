From: "Andrew Dixie" <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Wed, 6 Feb 2008 19:24:15 +1300
Message-ID: <003301c86888$ed735a20$0301a8c0@MURTLE>
References: <20080205090132.GA8286@stro.at> <1202248931.12271.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Cc: <linux-nfs@vger.kernel.org>, "maximilian attems" <max-U9r9yeDMy7A@public.gmane.org>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mta02.xtra.co.nz ([210.54.141.253]:45700 "EHLO mta02.xtra.co.nz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755231AbYBFHGB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 02:06:01 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The fact that the delegreturn call appears to have hit xprt_timer is
> interesting. Under normal circumstances, timeouts should never occur
> under NFSv4. Could you tell us what mount options you're using here?
>
> Also please could you confirm for us that the server is still up and
> responding to requests from other clients.

The mount options were defaults:
i.e. mount -t nfs4 server:/mnt /mnt
sshd has died. I will confrim exactly what is in /proc/mounts when I get 
physical access.

The server is still up serving active nfsv3 clients. I mounted nfsv4 on 
another client and that worked too.

The following appears in the server logs:
Feb  4 08:28:01 devfile kernel: NFSD: setclientid: string in use by 
client(clientid 47945499/00001c88)
Feb  4 08:34:18 devfile kernel: NFSD: setclientid: string in use by 
client(clientid 47945499/00001c8d)
Feb  4 08:38:02 devfile kernel: NFSD: setclientid: string in use by 
client(clientid 47945499/00001c8f)
Feb  4 10:01:02 devfile kernel: NFSD: setclientid: string in use by 
client(clientid 47a627bd/00000002)
Feb  4 10:07:37 devfile kernel: NFSD: setclientid: string in use by 
client(clientid 47a627bd/00000005)
Feb  4 10:17:02 devfile kernel: NFSD: setclientid: string in use by 
client(clientid 47a627bd/0000019e)
Feb  5 07:59:58 devfile kernel: NFSD: setclientid: string in use by 
client(clientid 47a627bd/000003f2)
Feb  5 08:01:02 devfile kernel: NFSD: setclientid: string in use by 
client(clientid 47a627bd/000003f3)

These are not close to the times that it hung.
Prior to Feb 4 it occurs 10 to 50 times a day (from when the client was 
running 2.6.18 kernel)
There is only one nfsv4 client.

Thanks,
Andrew 

