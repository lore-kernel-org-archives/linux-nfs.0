Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:58046 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075Ab1C1U3w convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 16:29:52 -0400
Received: by iwn34 with SMTP id 34so4057744iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2011 13:29:52 -0700 (PDT)
In-Reply-To: <AANLkTi=YZhpAE4ei6HV=36mCq_vY0AbdiPaH0EghKDxU@mail.gmail.com>
References: <y2n3b6787961004170051qfce975c0tdbc14b7ea237504d@mail.gmail.com>
	<j2m3b6787961004170054o64f3cb47l38864ca402eb231b@mail.gmail.com>
	<AANLkTi=YZhpAE4ei6HV=36mCq_vY0AbdiPaH0EghKDxU@mail.gmail.com>
Date: Mon, 28 Mar 2011 16:29:51 -0400
Message-ID: <AANLkTinmxR5yMVoymY5pQc9Unidv19nUYsxFi7s4T0y1@mail.gmail.com>
Subject: Re: cannot mount nfsv4/krb5 with krb51.7, 1.8 and 1.8.1
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond, is it possible to push this fix for the 2.6.39? Thank you.

On Mon, Mar 28, 2011 at 4:26 PM, Olga Kornievskaia <aglo@citi.umich.edu> wrote:
> I'd like to 2nd this issue.
>
> the problem is in the kernel's derivation of the rc4 signature key.
> this is the commit that broke it.
>
> [aglo@skydive linux-pnfs]$ git show 411b5e05617593efebc06241dbc56f42150f2abe
> commit 411b5e05617593efebc06241dbc56f42150f2abe
> Author: Joe Perches <joe@perches.com>
> Date:   Mon Sep 13 12:48:01 2010 -0700
>
>    net/sunrpc: Use static const char arrays
>
>    Signed-off-by: Joe Perches <joe@perches.com>
>    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>
> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_
> index 0326446..8a4d083c 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
> @@ -422,7 +422,7 @@ static int
>  context_derive_keys_rc4(struct krb5_ctx *ctx)
>  {
>        struct crypto_hash *hmac;
> -       char sigkeyconstant[] = "signaturekey";
> +       static const char sigkeyconstant[] = "signaturekey";
>        int slen = strlen(sigkeyconstant) + 1;  /* include null terminator */
>        struct hash_desc desc;
>        struct scatterlist sg[1];
>
>
>
>
> On Sat, Apr 17, 2010 at 3:54 AM, Di Pe <dipeit@gmail.com> wrote:
>> Hi,
>>
>> this looks like an issue with kerberos, but not 100% sure:
>>
>> ##############
>>
>>
>> I have a working configuration for Kerberized NFSv4 using Active
>> Directory 2003 functional level using
>>  Kernel 2.6.27 with krb5 1.6.3 and gssd 1.1.3. openSUSE 11.1  When I
>> switch to openSUSE 11.2 (Kernel 2.6.31, krb5 1.70, gssd 1.1.3)
>> rpc.gssd -fvvvvv shows this error message (Failed to create machine
>> krb5 context) and gives me more errros like "gss_create_upcall for uid
>> 0 result -13" when I turn on rpc/nfs debugging using 'echo "65535" >
>> /proc/sys/sunrpc/rpc[nfs]_debug'
>>
>> handling krb5 upcall
>> Full hostname for 'COMPUTRON.MYDOMAIN.ORG' is 'computron.mydomain.org'
>> Full hostname for 'phsgrid-03.fhcrc.org' is 'phsgrid-03.mydomain.org'
>> Key table entry not found while getting keytab entry for
>> 'root/phsgrid-03.mydomain.org@MYDOMAIN.ORG'
>> Success getting keytab entry for 'nfs/phsgrid-03.mydomain.org@MYDOMAIN.ORG'
>> Successfully obtained machine credentials for principal
>> 'nfs/phsgrid-03.mydomain.org@MYDOMAIN.ORG' stored in ccache
>> 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG'
>> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG' are
>> good until 1271522236
>> using FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG as credentials cache for
>> machine creds
>> using environment variable to select krb5 ccache
>> FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG
>> creating context using fsuid 0 (save_uid 0)
>> creating tcp client for server COMPUTRON.MYDOMAIN.ORG
>> DEBUG: port already set to 2049
>> creating context with server nfs@COMPUTRON.MYDOMAIN.ORG
>> WARNING: Failed to create krb5 context for user with uid 0 for server
>> COMPUTRON.MYDOMAIN.ORG
>> WARNING: Failed to create machine krb5 context with credentials cache
>> FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG for server
>> COMPUTRON.MYDOMAIN.ORG
>> WARNING: Failed to create machine krb5 context with any credentials
>> cache for server COMPUTRON.MYDOMAIN.ORG
>> doing error downcall
>>
>>
>> now when replace krb5-1.7 with krb5-1.6.3 on openSUSE 11.2 everything
>> works again:
>>
>> handling krb5 upcall
>> Full hostname for 'computron.mydomain.org' is 'computron.mydomain.org'
>> Full hostname for 'panther5.mydomain.org' is 'panther5.mydomain.org'
>> Key table entry not found while getting keytab entry for
>> 'root/panther5.mydomain.org@MYDOMAIN.ORG'
>> Success getting keytab entry for 'nfs/panther5.mydomain.org@MYDOMAIN.ORG'
>> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG' are
>> good until 1271518766
>> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG' are
>> good until 1271518766
>> using FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG as credentials cache for
>> machine creds
>> using environment variable to select krb5 ccache
>> FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG
>> creating context using fsuid 0 (save_uid 0)
>> creating tcp client for server computron.mydomain.org
>> creating context with server nfs@computron.mydomain.org
>> DEBUG: serialize_krb5_ctx: lucid version!
>> prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
>> doing downcall
>>
>>
>> going to openSUSE11.3 (Kernel 2.6.34-rc3, gssd 1.2.1, krb5 1.8) does
>> not help either. executing
>> mount -t nfs4 -o rsize=65536,wsize=65536,sec=krb5 computron:/tmp_iscsi tmp_iscsi
>> gives me the very some error message
>>
>> after that I tried to install the rpm package of krb5 1.8.1 and also
>> 1.8.1 straight from source. I am always getting the same error message
>> "Failed to create krb5 context"
>>
>>> cat /etc/krb5.conf
>> [libdefaults]
>>        default_realm = FHCRC.ORG
>>        clockskew = 300
>>        allow_weak_crypto = true
>>        default_tkt_enctypes = des-cbc-crc
>>        default_tgs_enctypes = des-cbc-crc
>>        #default_tkt_enctypes = des-cbc-md5
>>        #default_tgs_enctypes = des-cbc-md5
>>        #default_tkt_enctypes = rc4-hmac
>>        #default_tgs_enctypes = rc4-hmac
>>        #kdc_req_checksum_type = -138
>>        #ap_req_checksum_type = -138
>>        #safe_checksum_type = -138
>>        #ccache_type = 3
>>        #pkinit_eku_checking = kpServerAuth
>>
>>>cat idmapd.conf
>> [General]
>> Verbosity = 0
>> Pipefs-Directory = /var/lib/nfs/rpc_pipefs
>> Domain = mydomain.org
>> Local-Realm = MYDOMAIN.ORG
>>
>>> klist -k -e -t
>> Keytab name: WRFILE:/etc/krb5.keytab
>> KVNO Timestamp         Principal
>> ---- ----------------- --------------------------------------------------------
>>   3 12/31/69 16:00:00 nfs/phsgrid-03.mydomain.org@MYDOMAIN.ORG (DES
>> cbc mode with CRC-32)
>>
>>
>> Thanks for your help
>>
>
