From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: cannot mount nfsv4/krb5 with krb51.7, 1.8 and 1.8.1
Date: Sat, 17 Apr 2010 08:55:28 -0400
Message-ID: <u2x4d569c331004170555mbc4ca310pb63e0e083955fc83@mail.gmail.com>
References: <y2n3b6787961004170051qfce975c0tdbc14b7ea237504d@mail.gmail.com>
	 <j2m3b6787961004170054o64f3cb47l38864ca402eb231b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Di Pe <dipeit@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f227.google.com ([209.85.217.227]:39099 "EHLO
	mail-gx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab0DQMz3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Apr 2010 08:55:29 -0400
Received: by gxk27 with SMTP id 27so2952745gxk.1
        for <linux-nfs@vger.kernel.org>; Sat, 17 Apr 2010 05:55:28 -0700 (PDT)
In-Reply-To: <j2m3b6787961004170054o64f3cb47l38864ca402eb231b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see that you already have "allow_weak_crypto =3D true".

If the NFS server is Linux, debug output from rpc.svcgssd there might
help.  If you are only changing the client (and not the server) then a
packet trace would be helpful.

On Sat, Apr 17, 2010 at 3:54 AM, Di Pe <dipeit@gmail.com> wrote:
> Hi,
>
> this looks like an issue with kerberos, but not 100% sure:
>
> ##############
>
>
> I have a working configuration for Kerberized NFSv4 using Active
> Directory 2003 functional level using
> =A0Kernel 2.6.27 with krb5 1.6.3 and gssd 1.1.3. openSUSE 11.1 =A0Whe=
n I
> switch to openSUSE 11.2 (Kernel 2.6.31, krb5 1.70, gssd 1.1.3)
> rpc.gssd -fvvvvv shows this error message (Failed to create machine
> krb5 context) and gives me more errros like "gss_create_upcall for ui=
d
> 0 result -13" when I turn on rpc/nfs debugging using 'echo "65535" >
> /proc/sys/sunrpc/rpc[nfs]_debug'
>
> handling krb5 upcall
> Full hostname for 'COMPUTRON.MYDOMAIN.ORG' is 'computron.mydomain.org=
'
> Full hostname for 'phsgrid-03.fhcrc.org' is 'phsgrid-03.mydomain.org'
> Key table entry not found while getting keytab entry for
> 'root/phsgrid-03.mydomain.org-7RAbkED+uC3Rnqqr4xx/QQ@public.gmane.org'
> Success getting keytab entry for 'nfs/phsgrid-03.mydomain.org@MYDOMAI=
N.ORG'
> Successfully obtained machine credentials for principal
> 'nfs/phsgrid-03.mydomain.org-7RAbkED+uC3Rnqqr4xx/QQ@public.gmane.org' stored in ccache
> 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG'
> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG' are
> good until 1271522236
> using FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG as credentials cache for
> machine creds
> using environment variable to select krb5 ccache
> FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG
> creating context using fsuid 0 (save_uid 0)
> creating tcp client for server COMPUTRON.MYDOMAIN.ORG
> DEBUG: port already set to 2049
> creating context with server nfs-T9a8nxb3NlRDRic5mGcqrdUwMMlcnPbI@public.gmane.org
> WARNING: Failed to create krb5 context for user with uid 0 for server
> COMPUTRON.MYDOMAIN.ORG
> WARNING: Failed to create machine krb5 context with credentials cache
> FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG for server
> COMPUTRON.MYDOMAIN.ORG
> WARNING: Failed to create machine krb5 context with any credentials
> cache for server COMPUTRON.MYDOMAIN.ORG
> doing error downcall
>
>
> now when replace krb5-1.7 with krb5-1.6.3 on openSUSE 11.2 everything
> works again:
>
> handling krb5 upcall
> Full hostname for 'computron.mydomain.org' is 'computron.mydomain.org=
'
> Full hostname for 'panther5.mydomain.org' is 'panther5.mydomain.org'
> Key table entry not found while getting keytab entry for
> 'root/panther5.mydomain.org-7RAbkED+uC3Rnqqr4xx/QQ@public.gmane.org'
> Success getting keytab entry for 'nfs/panther5.mydomain.org@MYDOMAIN.=
ORG'
> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG' are
> good until 1271518766
> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG' are
> good until 1271518766
> using FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG as credentials cache for
> machine creds
> using environment variable to select krb5 ccache
> FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG
> creating context using fsuid 0 (save_uid 0)
> creating tcp client for server computron.mydomain.org
> creating context with server nfs-rgSBCdXwyOrciAkCgRUzx7R8R3SVtaJk@public.gmane.org
> DEBUG: serialize_krb5_ctx: lucid version!
> prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and leng=
th 8
> doing downcall
>
>
> going to openSUSE11.3 (Kernel 2.6.34-rc3, gssd 1.2.1, krb5 1.8) does
> not help either. executing
> mount -t nfs4 -o rsize=3D65536,wsize=3D65536,sec=3Dkrb5 computron:/tm=
p_iscsi tmp_iscsi
> gives me the very some error message
>
> after that I tried to install the rpm package of krb5 1.8.1 and also
> 1.8.1 straight from source. I am always getting the same error messag=
e
> "Failed to create krb5 context"
>
>> cat /etc/krb5.conf
> [libdefaults]
> =A0 =A0 =A0 =A0default_realm =3D FHCRC.ORG
> =A0 =A0 =A0 =A0clockskew =3D 300
> =A0 =A0 =A0 =A0allow_weak_crypto =3D true
> =A0 =A0 =A0 =A0default_tkt_enctypes =3D des-cbc-crc
> =A0 =A0 =A0 =A0default_tgs_enctypes =3D des-cbc-crc
> =A0 =A0 =A0 =A0#default_tkt_enctypes =3D des-cbc-md5
> =A0 =A0 =A0 =A0#default_tgs_enctypes =3D des-cbc-md5
> =A0 =A0 =A0 =A0#default_tkt_enctypes =3D rc4-hmac
> =A0 =A0 =A0 =A0#default_tgs_enctypes =3D rc4-hmac
> =A0 =A0 =A0 =A0#kdc_req_checksum_type =3D -138
> =A0 =A0 =A0 =A0#ap_req_checksum_type =3D -138
> =A0 =A0 =A0 =A0#safe_checksum_type =3D -138
> =A0 =A0 =A0 =A0#ccache_type =3D 3
> =A0 =A0 =A0 =A0#pkinit_eku_checking =3D kpServerAuth
>
>>cat idmapd.conf
> [General]
> Verbosity =3D 0
> Pipefs-Directory =3D /var/lib/nfs/rpc_pipefs
> Domain =3D mydomain.org
> Local-Realm =3D MYDOMAIN.ORG
>
>> klist -k -e -t
> Keytab name: WRFILE:/etc/krb5.keytab
> KVNO Timestamp =A0 =A0 =A0 =A0 Principal
> ---- ----------------- ----------------------------------------------=
----------
> =A0 3 12/31/69 16:00:00 nfs/phsgrid-03.mydomain.org-7RAbkED+uC3Rnqqr4xx/QQ@public.gmane.org (DES
> cbc mode with CRC-32)
>
>
> Thanks for your help
>
