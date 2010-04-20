Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45608 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab0DTAhr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 20:37:47 -0400
Received: by vws5 with SMTP id 5so2560431vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 19 Apr 2010 17:37:46 -0700 (PDT)
In-Reply-To: <20100417111001.255ad1f4@tlielax.poochiereds.net>
References: <y2n3b6787961004170051qfce975c0tdbc14b7ea237504d@mail.gmail.com>
	 <j2m3b6787961004170054o64f3cb47l38864ca402eb231b@mail.gmail.com>
	 <20100417111001.255ad1f4@tlielax.poochiereds.net>
Date: Mon, 19 Apr 2010 17:37:45 -0700
Message-ID: <x2l3b6787961004191737p1fb222uc6a5b03d77414826@mail.gmail.com>
Subject: Re: cannot mount nfsv4/krb5 with krb51.7, 1.8 and 1.8.1
From: Di Pe <dipeit@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks Jeff,

that's an interesting issue:  https://bugzilla.redhat.com/show_bug.cgi?id=562807

I think the default change to --enable-tirpc was made in gssd 1.2.x
but one of my configurations that is not working is running nfs-client
1.1.3  (the current openSUSE 11.2/ kernel 2.6.31.12, krb5 1.7).

Nonetheless I patched libtirpc and then also compiled nfs-client with
--disable-tirpc both on openSUSE 11.2 and openSUSE 11.3. None of these
4 independent tests worked.

After that I went back to the test that was originally successful: I
also installed krb5 1.6.3 on openSUS11.3 replacing krb5 1.8 and voila
it worked flawlessly. I think I need to go through the change logs
again. I would be glad if someone could give me some hints how I could
get additional levels of debugging?

On another Note: This PAC size issue is interesting. It seems to be an
ongoing problem over the last couple of years. I suspect most
krb5/gssd developers do not have an Active Directory infrastructure at
hand they can test against?
Going forward it may be make sense to "fix" this issue on the
Microsoft end of things : http://support.microsoft.com/kb/832572 ?
However, this would result in a pretty unique environment because many
AD Admins would not bother with this setting nor would they know how
to apply it.

thanks for your help so far.

I will test other distributions and see if that is any different.


On Sat, Apr 17, 2010 at 8:10 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Sat, 17 Apr 2010 00:54:38 -0700
> Di Pe <dipeit@gmail.com> wrote:
>
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
>> > cat /etc/krb5.conf
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
>> >cat idmapd.conf
>> [General]
>> Verbosity = 0
>> Pipefs-Directory = /var/lib/nfs/rpc_pipefs
>> Domain = mydomain.org
>> Local-Realm = MYDOMAIN.ORG
>>
>> > klist -k -e -t
>> Keytab name: WRFILE:/etc/krb5.keytab
>> KVNO Timestamp         Principal
>> ---- ----------------- --------------------------------------------------------
>>   3 12/31/69 16:00:00 nfs/phsgrid-03.mydomain.org@MYDOMAIN.ORG (DES
>> cbc mode with CRC-32)
>>
>>
>> Thanks for your help
>
> Is the new nfs-utils compiled against libtirpc and the old one not? If
> so the problem may be that libtirpc wasn't allowing large enough
> tickets (AD tickets can be pretty large due to the presence of the PAC).
>
> Recent libtirpc has a patch which seems to fix this problem:
>
>    [PATCH] libtirpc: allow larger ticket sizes with RPCSEC_GSS
>
> --
> Jeff Layton <jlayton@redhat.com>
>
