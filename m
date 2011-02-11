Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54060 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758320Ab1BKW66 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Feb 2011 17:58:58 -0500
Received: by bwz15 with SMTP id 15so3711121bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 14:58:57 -0800 (PST)
In-Reply-To: <AANLkTinSC8E1-Ym_KMn+jwUrjgdcEiBpQo=CazY6z9cV@mail.gmail.com>
References: <AANLkTinSC8E1-Ym_KMn+jwUrjgdcEiBpQo=CazY6z9cV@mail.gmail.com>
Date: Fri, 11 Feb 2011 17:58:56 -0500
Message-ID: <AANLkTikCw+5DjYDtPZGNLATLA85E9Zr-2TbkCWAZ0F8d@mail.gmail.com>
Subject: Re: Problems with Krb5/Nfs4, misconfiguration, bug or incompatibility?
From: Kevin Coffman <kwc@citi.umich.edu>
To: CeR <cer.inet@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 11, 2011 at 1:38 PM, CeR <cer.inet@gmail.com> wrote:
>
> Hello. I have been trying to set up a local-teachpurpose-server at home.
>
> My enviroment: debian squeeze KVM/libvirt machine, with 2.6.32-5-amd64 kernel.
>
> When restarting services with the correct configuration, i get this:
> As you can see, the keytab is there, with correct permissions to read by root.
>
> root@goku:~# /etc/init.d/nfs-common restart
> Stopping NFS common utilities: gssd idmapd statd.
> Starting NFS common utilities: statd idmapd gssd.
>
> root@goku:~# /etc/init.d/nfs-kernel-server restart
> Stopping NFS kernel daemon: mountd svcgssd nfsd.
> Unexporting directories for NFS kernel daemon....
> Exporting directories for NFS kernel daemon....
> Starting NFS kernel daemon: nfsd svcgssd failed!
>
> root@goku:~# tail /var/log/syslog
> Feb 11 18:29:45 goku kernel: [ 2266.025197] nfsd: last server has
> exited, flushing export cache
> Feb 11 18:29:46 goku kernel: [ 2267.119699] svc: failed to register
> lockdv1 RPC service (errno 97).
> Feb 11 18:29:46 goku kernel: [ 2267.121318] NFSD: Using
> /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> Feb 11 18:29:46 goku kernel: [ 2267.122284] NFSD: starting 90-second
> grace period
> Feb 11 18:29:46 goku rpc.svcgssd[2333]: ERROR: GSS-API: error in
> gss_acquire_cred(): Unspecified GSS failure.  Minor code may provide
> more information - Key table entry not found
> Feb 11 18:29:46 goku rpc.svcgssd[2333]: unable to obtain root
> (machine) credentials
> Feb 11 18:29:46 goku rpc.svcgssd[2333]: do you have a keytab entry for
> nfs/<your.host>@<YOUR.REALM> in /etc/krb5.keytab?
>
> root@goku:~# ls -l /etc/krb5.keytab
> -rw-r----- 1 root openldap 1210 feb 11 11:11 /etc/krb5.keytab
>
> root@goku:~# klist -k
> Keytab name: WRFILE:/etc/krb5.keytab
> KVNO Principal
> ---- --------------------------------------------------------------------------
>   2 host/goku.example.com@EXAMPLE.COM
>   2 host/goku.example.com@EXAMPLE.COM
>   2 host/goku.example.com@EXAMPLE.COM
>   2 host/goku.example.com@EXAMPLE.COM
>   2 ldap/goku.example.com@EXAMPLE.COM
>   2 ldap/goku.example.com@EXAMPLE.COM
>   2 ldap/goku.example.com@EXAMPLE.COM
>   2 ldap/goku.example.com@EXAMPLE.COM
>   4 nfs/goku.example.com@EXAMPLE.COM
>   4 nfs/goku.example.com@EXAMPLE.COM
>   4 nfs/goku.example.com@EXAMPLE.COM
>   4 nfs/goku.example.com@EXAMPLE.COM
>
>
> Is a bug? A incompatibility between my packages versions? A
> configuration problem? Any idea?
>
>
> Thank you. Best regards.

First, with this kernel version, you should only have one keytab entry
for nfs/goku.example.com with a DES key.  (You don't show the
enctypes, but I see you have 4 keys for nfs.)  You won't hit this
problem until you get past the other error.

Make sure the reverse look-up for your server's host returns the
correct name.  (Matching the name in the keytab, "goku.example.com")

Perhaps send a copy of /etc/hosts and your /etc/krb5.conf to see what
might be misconfigured.

K.C.
