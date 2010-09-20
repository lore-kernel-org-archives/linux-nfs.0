Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33307 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752119Ab0ITO6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 10:58:07 -0400
Date: Mon, 20 Sep 2010 10:56:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: George Mamalakis <mamalos@eng.auth.gr>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsv3 gssapi client?
Message-ID: <20100920145643.GD4580@fieldses.org>
References: <4C938F3B.4030604@eng.auth.gr>
 <20100917174328.GC25515@fieldses.org>
 <4C972DB3.2050405@eng.auth.gr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C972DB3.2050405@eng.auth.gr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 20, 2010 at 12:47:31PM +0300, George Mamalakis wrote:
>  Hi Bruce and thanx for the reply,
> 
> to your questions now:
> 
> On 17/09/2010 20:43, J. Bruce Fields wrote:
> >
> >># mount -t nfs -o sec=krb5 fbsdserver:/exports /mnt
> >>
> >Was there supposed to be some error output there?  Or did the mount just
> >hang?
> >
> The mount command stalls and no output is presented; only the
> messages on /var/log/messages.
> >>Sep 17 16:06:01 linuxclient kernel: svc: failed to register lockdv1
> >>RPC service (errno 111).
> >111 is ECONNREFUSED.  I'm not sure why that's failing.  (Should failure
> >to register lockd fail the whole mount?  I thought it would at worst
> >result in ENOLCK on lock requests?) Do you get better results if you
> >mount with nolock?
> >
> Now this is peculiar. If run mount -o nolock then gssd segfaults.
> This is because it creates a /tmp/krb5cc_machine_REALM ticket, and
> when it access it, it segfaults.

Ouch.  Well, that's a problem.

(And have you checked the log files to make sure it's gssd segfaulting
and not some kind of crash in the kernel?)

--b.

> To overcome this issue I deleted
> the temporary file, and ran gssd manually to see its output. So,
> mount returned the following:
> 
> [root@linuxclient ~]# mount -t nfs -o sec=krb5,nolock
> fbsdserver:/exports /mnt
> mount.nfs: access denied by server while mounting fbsdserver:/exports
> 
> and gssd console output read:
> 
> destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt110
> handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt112)
> handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
> handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt112)
> process_krb5_upcall: service is '<null>'
> getting credentials for client with uid 0 for server fbsdserver
> WARNING: Failed to create krb5 context for user with uid 0 for
> server fbsdserver
> doing error downcall
> destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt113
> handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt112)
> handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
> handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt112)
> process_krb5_upcall: service is '<null>'
> getting credentials for client with uid 0 for server fbsdserver
> WARNING: Failed to create krb5 context for user with uid 0 for
> server fbsdserver
> doing error downcall
> handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt112)
> handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
> handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt112)
> process_krb5_upcall: service is '<null>'
> getting credentials for client with uid 0 for server fbsdclient.ee.auth.gr
> WARNING: Failed to create krb5 context for user with uid 0 for
> server fbsdserver
> doing error downcall
> destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt112
> destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt111
> 
> /var/log/messages shows nothing.
> 
> 
> I think that's all regarding your questions.
> 
> Thanx again,
> 
> mamalos.
> 
> -- 
> George Mamalakis
> 
> IT Officer
> Electrical and Computer Engineer (Aristotle Un. of Thessaloniki),
> MSc (Imperial College of London)
> 
> Department of Electrical and Computer Engineering
> Faculty of Engineering
> Aristotle University of Thessaloniki
> 
> phone number : +30 (2310) 994379
> 
