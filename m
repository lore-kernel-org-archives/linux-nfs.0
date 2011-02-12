Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:51089 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929Ab1BLMt0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Feb 2011 07:49:26 -0500
Received: by qwa26 with SMTP id 26so2160179qwa.19
        for <linux-nfs@vger.kernel.org>; Sat, 12 Feb 2011 04:49:25 -0800 (PST)
In-Reply-To: <AANLkTikCw+5DjYDtPZGNLATLA85E9Zr-2TbkCWAZ0F8d@mail.gmail.com>
References: <AANLkTinSC8E1-Ym_KMn+jwUrjgdcEiBpQo=CazY6z9cV@mail.gmail.com> <AANLkTikCw+5DjYDtPZGNLATLA85E9Zr-2TbkCWAZ0F8d@mail.gmail.com>
From: CeR <cer.inet@gmail.com>
Date: Sat, 12 Feb 2011 13:49:05 +0100
Message-ID: <AANLkTiknt45jxzBP6_oKdFA2LFU5Hk+aAwuyGsM9LkSz@mail.gmail.com>
Subject: Re: Problems with Krb5/Nfs4, misconfiguration, bug or incompatibility?
To: Kevin Coffman <kwc@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thank you, i will take a look  to the enctypes of my keytab. I hope
that's the problem.



Here /etc/krb5.conf

-----------------------------------------------------------------------
[libdefaults]
        default_realm = EXAMPLE.COM

# The following krb5.conf variables are only for MIT Kerberos.
        krb4_config = /etc/krb.conf
        krb4_realms = /etc/krb.realms
        kdc_timesync = 1
        ccache_type = 4
        forwardable = true
        proxiable = true

#       default_tgs_enctypes = des3-hmac-sha1
#       default_tkt_enctypes = des3-hmac-sha1
#       permitted_enctypes = des3-hmac-sha1

# The following libdefaults parameters are only for Heimdal Kerberos.
        v4_instance_resolve = false
        v4_name_convert = {
                host = {
                        rcmd = host
                        ftp = ftp
                }
                plain = {
                        something = something-else
                }
        }
        fcc-mit-ticketflags = true

[realms]
        EXAMPLE.COM = {
                kdc = kerberos.example.com
                admin_server = kerberos.example.com
        }
[domain_realm]
        .example.com = EXAMPLE.COM
        example.com = EXAMPLE.COM

[login]
        krb4_convert = true
        krb4_get_tickets = false
--------------------------------------------------------------------------------
Here /etc/hosts

127.0.0.1       localhost goku goku.example.com nfs.example.com
10.0.0.1        goku goku.example.com
10.0.0.1        nfs.example.com

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts









2011/2/11 Kevin Coffman <kwc@citi.umich.edu>:
> On Fri, Feb 11, 2011 at 1:38 PM, CeR <cer.inet@gmail.com> wrote:
>>
>> Hello. I have been trying to set up a local-teachpurpose-server at home.
>>
>> My enviroment: debian squeeze KVM/libvirt machine, with 2.6.32-5-amd64 kernel.
>>
>> When restarting services with the correct configuration, i get this:
>> As you can see, the keytab is there, with correct permissions to read by root.
>>
>> root@goku:~# /etc/init.d/nfs-common restart
>> Stopping NFS common utilities: gssd idmapd statd.
>> Starting NFS common utilities: statd idmapd gssd.
>>
>> root@goku:~# /etc/init.d/nfs-kernel-server restart
>> Stopping NFS kernel daemon: mountd svcgssd nfsd.
>> Unexporting directories for NFS kernel daemon....
>> Exporting directories for NFS kernel daemon....
>> Starting NFS kernel daemon: nfsd svcgssd failed!
>>
>> root@goku:~# tail /var/log/syslog
>> Feb 11 18:29:45 goku kernel: [ 2266.025197] nfsd: last server has
>> exited, flushing export cache
>> Feb 11 18:29:46 goku kernel: [ 2267.119699] svc: failed to register
>> lockdv1 RPC service (errno 97).
>> Feb 11 18:29:46 goku kernel: [ 2267.121318] NFSD: Using
>> /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
>> Feb 11 18:29:46 goku kernel: [ 2267.122284] NFSD: starting 90-second
>> grace period
>> Feb 11 18:29:46 goku rpc.svcgssd[2333]: ERROR: GSS-API: error in
>> gss_acquire_cred(): Unspecified GSS failure.  Minor code may provide
>> more information - Key table entry not found
>> Feb 11 18:29:46 goku rpc.svcgssd[2333]: unable to obtain root
>> (machine) credentials
>> Feb 11 18:29:46 goku rpc.svcgssd[2333]: do you have a keytab entry for
>> nfs/<your.host>@<YOUR.REALM> in /etc/krb5.keytab?
>>
>> root@goku:~# ls -l /etc/krb5.keytab
>> -rw-r----- 1 root openldap 1210 feb 11 11:11 /etc/krb5.keytab
>>
>> root@goku:~# klist -k
>> Keytab name: WRFILE:/etc/krb5.keytab
>> KVNO Principal
>> ---- --------------------------------------------------------------------------
>>   2 host/goku.example.com@EXAMPLE.COM
>>   2 host/goku.example.com@EXAMPLE.COM
>>   2 host/goku.example.com@EXAMPLE.COM
>>   2 host/goku.example.com@EXAMPLE.COM
>>   2 ldap/goku.example.com@EXAMPLE.COM
>>   2 ldap/goku.example.com@EXAMPLE.COM
>>   2 ldap/goku.example.com@EXAMPLE.COM
>>   2 ldap/goku.example.com@EXAMPLE.COM
>>   4 nfs/goku.example.com@EXAMPLE.COM
>>   4 nfs/goku.example.com@EXAMPLE.COM
>>   4 nfs/goku.example.com@EXAMPLE.COM
>>   4 nfs/goku.example.com@EXAMPLE.COM
>>
>>
>> Is a bug? A incompatibility between my packages versions? A
>> configuration problem? Any idea?
>>
>>
>> Thank you. Best regards.
>
> First, with this kernel version, you should only have one keytab entry
> for nfs/goku.example.com with a DES key.  (You don't show the
> enctypes, but I see you have 4 keys for nfs.)  You won't hit this
> problem until you get past the other error.
>
> Make sure the reverse look-up for your server's host returns the
> correct name.  (Matching the name in the keytab, "goku.example.com")
>
> Perhaps send a copy of /etc/hosts and your /etc/krb5.conf to see what
> might be misconfigured.
>
> K.C.
>



-- 
[*] CeR / Arturo Borrero Gonzalez [*]
