Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:56765 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab1CWClM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 22:41:12 -0400
Received: by qyg14 with SMTP id 14so6703653qyg.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Mar 2011 19:41:11 -0700 (PDT)
In-Reply-To: <imbb8m$uiv$1@dough.gmane.org>
References: <imbb8m$uiv$1@dough.gmane.org>
Date: Tue, 22 Mar 2011 22:41:11 -0400
Message-ID: <AANLkTimFJ2fMn805jY91u8FQihib8GfJ=8S7Yy4y47R3@mail.gmail.com>
Subject: Re: different kernels mean NFS4/GSSAPI works or doesn't
From: Kevin Coffman <kwc@citi.umich.edu>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Brian,
Can you tell me how you removed the 3des keys from the keytab?  (If
you simply used ktutil, this isn't good enough.  The KDC will still
issue a ticket with 3DES because, as far as it knows, the service
still has a 3des key in the KDC and supports 3des.)

(Sorry if this was already provided and I missed it.)  Do you have
output from gssd and svcgssd in the original failure/hang case?

K.C.

On Tue, Mar 22, 2011 at 7:27 PM, Brian J. Murrell <brian@interlinx.bc.ca> wrote:
> I was hoping I could bring a kernel.org ticket that I filed to your
> attention in the hopes that somebody might have an epiphany.
>
> https://bugzilla.kernel.org/show_bug.cgi?id=31442
>
> This is a strange problem where simply booting to a different kernel,
> even within the same release stream (2.6.32) can result in an NFS server
> that doesn't seem to want to respond to GSSAPI mount requests.
>
> I was working with Trond on it and it got as far as my reporting what
> rpc.gssd is doing when a failed (blocked in fact) mount request happens:
>
> pc# rpc.gssd with the -f -vvv
> beginning poll
> handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt6e1)
> handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
> handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt6e1)
> process_krb5_upcall: service is '<null>'
> Full hostname for 'linux.example.com' is 'linux.example.com'
> Full hostname for 'pc' is 'pc'
> Key table entry not found while getting keytab entry for 'root/pc@ILINX'
> Key table entry not found while getting keytab entry for 'nfs/pc@ILINX'
> Key table entry not found while getting keytab entry for 'host/pc@ILINX'
> Success getting keytab entry for nfs/*@ILINX
> WARNING: Key table entry not found while getting initial ticket for
> principal
> 'nfs/pc.example.com@ILINX' using keytab 'WRFILE:/etc/krb5.keytab'
> ERROR: No credentials found for connection to server linux.example.com
> doing error downcall
> destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6e1
> destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6e0
> destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6df
> destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6e4
> destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6e3
>
> pc$ sudo mount -t nfs4 -o sec=krb5 linux:/tmp /mnt/tmp
> mount.nfs4: access denied by server while mounting linux:/tmp
>
> Now granted, this isn't a block/hang on the mount, but this was also
> after having removed 3des entries from my keytabs.  I wasn't getting
> access denied before removing the 3des keytab entries but was getting
> blocked mount.nfs4 commands on the client.
>
> More gory details are in the ticket.
>
> Any next debugging steps?
>
> Cheers,
> b.
>
>
