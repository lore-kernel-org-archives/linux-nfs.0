Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59451 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669Ab0DONRN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Apr 2010 09:17:13 -0400
Received: by gyg13 with SMTP id 13so733689gyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2010 06:17:12 -0700 (PDT)
In-Reply-To: <4BC6F9AF.6070509@RedHat.com>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>
	 <y2t4d569c331004141130z7525d001gcdb81db5b1ede42e@mail.gmail.com>
	 <4BC6F9AF.6070509@RedHat.com>
Date: Thu, 15 Apr 2010 09:17:04 -0400
Message-ID: <r2x4d569c331004150617t9e26953x13e3097f76d6f209@mail.gmail.com>
Subject: Re: [PATCH 10/22] gss_krb5: Add upcall info indicating supported
	kerberos enctypes
From: Kevin Coffman <kwc@citi.umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Apr 15, 2010 at 7:34 AM, Steve Dickson <SteveD@redhat.com> wrote:
> On 04/14/2010 02:30 PM, Kevin Coffman wrote:
>>> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
>>> index 8b612e7..d96d824 100644
>>> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
>>> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
>>> @@ -552,6 +552,7 @@ static struct gss_api_mech gss_kerberos_mech = {
>>>        .gm_ops         = &gss_kerberos_ops,
>>>        .gm_pf_num      = ARRAY_SIZE(gss_kerberos_pfs),
>>>        .gm_pfs         = gss_kerberos_pfs,
>>> +       .gm_upcall_enctypes = "enctypes=1,2,3 ",
>>>  };
>>
>> Hi Trond,
>> This list should be in preference order.  It doesn't matter much with
>> this one, but the preferred order for DES is usually "3,1,2".
>>
>> When adding 3DES, the list should be "16,3,1,2"
>> When adding AES, it should be "18,17,16,3,1,2"
>> When adding RC4, it should be "18,17,16,23,3,1,2"
> Ok... I went back and took a second look at this... The first
> thing I did was put the gm_upcall_enctypes list back in
> preference order. I had no idea there was actually a theory
> behind the order...
>
> Side Note: It appears the ordering really does not matter
> because the KDC is the one that decides (via the TGS-REP) which
> enctype will be used and (I've been told) the KDC will always
> pick the highest enctype possible.
>
> Now the reason root was not getting its context was
> basically because of the following error (which I missed)
>    ERROR: prepare_krb5_rfc_cfx_buffer: not implemented
>
> Which was introduced by the third nfs-utils patch
> (Add support for non-DES encryption types)
> I'm currently investigating what that means...
>
> So, Trond its up to you if you want to put that
> list back in preference order, it will not matter
> to the user space code...
>
> steved.
>
>

I still contend that the order we send matters.  This is from MIT
1.6.3 KDC code:

/*
 * This function returns the keytype which should be selected for the
 * session key.  It is based on the ordered list which the user
 * requested, and what the KDC and the application server can support.
 */
krb5_enctype
select_session_keytype(krb5_context context, krb5_db_entry *server,
                       int nktypes, krb5_enctype *ktype)
