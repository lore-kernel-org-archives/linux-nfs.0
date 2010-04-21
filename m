Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:37245 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab0DUATg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Apr 2010 20:19:36 -0400
Received: by iwn35 with SMTP id 35so3479376iwn.21
        for <linux-nfs@vger.kernel.org>; Tue, 20 Apr 2010 17:19:35 -0700 (PDT)
In-Reply-To: <t2q4d569c331004200619le2dc3a2em52f27a830d4e7d95@mail.gmail.com>
References: <y2n3b6787961004170051qfce975c0tdbc14b7ea237504d@mail.gmail.com>
	 <j2m3b6787961004170054o64f3cb47l38864ca402eb231b@mail.gmail.com>
	 <20100417111001.255ad1f4@tlielax.poochiereds.net>
	 <x2l3b6787961004191737p1fb222uc6a5b03d77414826@mail.gmail.com>
	 <t2q4d569c331004200619le2dc3a2em52f27a830d4e7d95@mail.gmail.com>
Date: Tue, 20 Apr 2010 17:19:35 -0700
Message-ID: <j2y3b6787961004201719h6d3a7a6nea8f9d6e664a1cbc@mail.gmail.com>
Subject: Re: cannot mount nfsv4/krb5 with krb51.7, 1.8 and 1.8.1
From: Di Pe <dipeit@gmail.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Apr 20, 2010 at 6:19 AM, Kevin Coffman <kwc@citi.umich.edu> wrote:
> Hi,
>
> If I read this right, you replaced krb5-1.8.1 with krb5-1.6.3 and it
> fixed the problem?
>
> As I noted in your original message, you had "allow_weak_crypto =
> true" in your krb5.conf.  For NFS, this is required with krb5-1.8
> where DES is disabled by default.  Are you certain you have this
> specified in your krb5-1.8.1 /etc/krb5.conf?


Yes, I'm positive. 1.8.1 does not work 1.6.3 does!  This is my current setting

[libdefaults]
        default_realm = FHCRC.ORG
        clockskew = 300
        default_tkt_enctypes = des-cbc-crc
        default_tgs_enctypes = des-cbc-crc
        permitted_enctypes = des-cbc-crc
        allow_weak_crypto = true
        forwardable = true

I should add one more thing: I was using 2 different NFS servers, a
NetApp 7.3.1.1 and Opentext NFS Maestro Server 2008 (formerly
Hummingbird) on Windows 2008 R2 (AD is still 2003 R2). I found out
today that the NetApp had a corrupted keytab and after repairing that
it works fine with 1.8.1. NFS Maestro still only works with 1.6.3.
Since I can use the 1.6.3 rpm package onto newer distros I can live
with it for the moment if i block the rpm from getting updated but
it's still kind of a hack.


>
> K.C.
>
> On Mon, Apr 19, 2010 at 8:37 PM, Di Pe <dipeit@gmail.com> wrote:
>> Thanks Jeff,
>>
>> that's an interesting issue:  https://bugzilla.redhat.com/show_bug.cgi?id=562807
>>
>> I think the default change to --enable-tirpc was made in gssd 1.2.x
>> but one of my configurations that is not working is running nfs-client
>> 1.1.3  (the current openSUSE 11.2/ kernel 2.6.31.12, krb5 1.7).
>>
>> Nonetheless I patched libtirpc and then also compiled nfs-client with
>> --disable-tirpc both on openSUSE 11.2 and openSUSE 11.3. None of these
>> 4 independent tests worked.
>>
>> After that I went back to the test that was originally successful: I
>> also installed krb5 1.6.3 on openSUS11.3 replacing krb5 1.8 and voila
>> it worked flawlessly. I think I need to go through the change logs
>> again. I would be glad if someone could give me some hints how I could
>> get additional levels of debugging?
>>
>> On another Note: This PAC size issue is interesting. It seems to be an
>> ongoing problem over the last couple of years. I suspect most
>> krb5/gssd developers do not have an Active Directory infrastructure at
>> hand they can test against?
>> Going forward it may be make sense to "fix" this issue on the
>> Microsoft end of things : http://support.microsoft.com/kb/832572 ?
>> However, this would result in a pretty unique environment because many
>> AD Admins would not bother with this setting nor would they know how
>> to apply it.
>>
>> thanks for your help so far.
>>
>> I will test other distributions and see if that is any different.
>>
>>
>> On Sat, Apr 17, 2010 at 8:10 AM, Jeff Layton <jlayton@redhat.com> wrote:
>>> On Sat, 17 Apr 2010 00:54:38 -0700
>>> Di Pe <dipeit@gmail.com> wrote:
>>>
>>>> Hi,
>>>>
>>>> this looks like an issue with kerberos, but not 100% sure:
>>>>
>>>> ##############
>>>>
>>>>
>>>> I have a working configuration for Kerberized NFSv4 using Active
>>>> Directory 2003 functional level using
>>>>  Kernel 2.6.27 with krb5 1.6.3 and gssd 1.1.3. openSUSE 11.1  When I
>>>> switch to openSUSE 11.2 (Kernel 2.6.31, krb5 1.70, gssd 1.1.3)
>>>> rpc.gssd -fvvvvv shows this error message (Failed to create machine
>>>> krb5 context) and gives me more errros like "gss_create_upcall for uid
>>>> 0 result -13" when I turn on rpc/nfs debugging using 'echo "65535" >
>>>> /proc/sys/sunrpc/rpc[nfs]_debug'
>>>>
>>>> handling krb5 upcall
>>>> Full hostname for 'COMPUTRON.MYDOMAIN.ORG' is 'computron.mydomain.org'
>>>> Full hostname for 'phsgrid-03.fhcrc.org' is 'phsgrid-03.mydomain.org'
>>>> Key table entry not found while getting keytab entry for
>>>> 'root/phsgrid-03.mydomain.org@MYDOMAIN.ORG'
>>>> Success getting keytab entry for 'nfs/phsgrid-03.mydomain.org@MYDOMAIN.ORG'
>>>> Successfully obtained machine credentials for principal
>>>> 'nfs/phsgrid-03.mydomain.org@MYDOMAIN.ORG' stored in ccache
>>>> 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG'
>>>> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG' are
>>>> good until 1271522236
>>>> using FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG as credentials cache for
>>>> machine creds
>>>> using environment variable to select krb5 ccache
>>>> FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG
>>>> creating context using fsuid 0 (save_uid 0)
>>>> creating tcp client for server COMPUTRON.MYDOMAIN.ORG
>>>> DEBUG: port already set to 2049
>>>> creating context with server nfs@COMPUTRON.MYDOMAIN.ORG
>>>> WARNING: Failed to create krb5 context for user with uid 0 for server
>>>> COMPUTRON.MYDOMAIN.ORG
>>>> WARNING: Failed to create machine krb5 context with credentials cache
>>>> FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG for server
>>>> COMPUTRON.MYDOMAIN.ORG
>>>> WARNING: Failed to create machine krb5 context with any credentials
>>>> cache for server COMPUTRON.MYDOMAIN.ORG
>>>> doing error downcall
>>>>
>>>>
>>>> now when replace krb5-1.7 with krb5-1.6.3 on openSUSE 11.2 everything
>>>> works again:
>>>>
>>>> handling krb5 upcall
>>>> Full hostname for 'computron.mydomain.org' is 'computron.mydomain.org'
>>>> Full hostname for 'panther5.mydomain.org' is 'panther5.mydomain.org'
>>>> Key table entry not found while getting keytab entry for
>>>> 'root/panther5.mydomain.org@MYDOMAIN.ORG'
>>>> Success getting keytab entry for 'nfs/panther5.mydomain.org@MYDOMAIN.ORG'
>>>> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG' are
>>>> good until 1271518766
>>>> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG' are
>>>> good until 1271518766
>>>> using FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG as credentials cache for
>>>> machine creds
>>>> using environment variable to select krb5 ccache
>>>> FILE:/tmp/krb5cc_machine_MYDOMAIN.ORG
>>>> creating context using fsuid 0 (save_uid 0)
>>>> creating tcp client for server computron.mydomain.org
>>>> creating context with server nfs@computron.mydomain.org
>>>> DEBUG: serialize_krb5_ctx: lucid version!
>>>> prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
>>>> doing downcall
>>>>
>>>>
>>>> going to openSUSE11.3 (Kernel 2.6.34-rc3, gssd 1.2.1, krb5 1.8) does
>>>> not help either. executing
>>>> mount -t nfs4 -o rsize=65536,wsize=65536,sec=krb5 computron:/tmp_iscsi tmp_iscsi
>>>> gives me the very some error message
>>>>
>>>> after that I tried to install the rpm package of krb5 1.8.1 and also
>>>> 1.8.1 straight from source. I am always getting the same error message
>>>> "Failed to create krb5 context"
>>>>
>>>> > cat /etc/krb5.conf
>>>> [libdefaults]
>>>>        default_realm = FHCRC.ORG
>>>>        clockskew = 300
>>>>        allow_weak_crypto = true
>>>>        default_tkt_enctypes = des-cbc-crc
>>>>        default_tgs_enctypes = des-cbc-crc
>>>>        #default_tkt_enctypes = des-cbc-md5
>>>>        #default_tgs_enctypes = des-cbc-md5
>>>>        #default_tkt_enctypes = rc4-hmac
>>>>        #default_tgs_enctypes = rc4-hmac
>>>>        #kdc_req_checksum_type = -138
>>>>        #ap_req_checksum_type = -138
>>>>        #safe_checksum_type = -138
>>>>        #ccache_type = 3
>>>>        #pkinit_eku_checking = kpServerAuth
>>>>
>>>> >cat idmapd.conf
>>>> [General]
>>>> Verbosity = 0
>>>> Pipefs-Directory = /var/lib/nfs/rpc_pipefs
>>>> Domain = mydomain.org
>>>> Local-Realm = MYDOMAIN.ORG
>>>>
>>>> > klist -k -e -t
>>>> Keytab name: WRFILE:/etc/krb5.keytab
>>>> KVNO Timestamp         Principal
>>>> ---- ----------------- --------------------------------------------------------
>>>>   3 12/31/69 16:00:00 nfs/phsgrid-03.mydomain.org@MYDOMAIN.ORG (DES
>>>> cbc mode with CRC-32)
>>>>
>>>>
>>>> Thanks for your help
>>>
>>> Is the new nfs-utils compiled against libtirpc and the old one not? If
>>> so the problem may be that libtirpc wasn't allowing large enough
>>> tickets (AD tickets can be pretty large due to the presence of the PAC).
>>>
>>> Recent libtirpc has a patch which seems to fix this problem:
>>>
>>>    [PATCH] libtirpc: allow larger ticket sizes with RPCSEC_GSS
>>>
>>> --
>>> Jeff Layton <jlayton@redhat.com>
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>
