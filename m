Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:61551 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab0CANy0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Mar 2010 08:54:26 -0500
Received: by bwz1 with SMTP id 1so73081bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 01 Mar 2010 05:54:24 -0800 (PST)
In-Reply-To: <4B8BC02A.5020702@RedHat.com>
References: <39d46ab51002221033n78035811y959fdd30b155b174@mail.gmail.com>
	 <4B8BC02A.5020702@RedHat.com>
Date: Mon, 1 Mar 2010 08:54:24 -0500
Message-ID: <4d569c331003010554r7ed5e51p135669522bf16b81@mail.gmail.com>
Subject: Re: [PATCH] gssd: By default, don't spam syslog when users'
	credentials expire (redux)
From: Kevin Coffman <kwc@citi.umich.edu>
To: Andrew Pollock <apollock@google.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 1, 2010 at 8:24 AM, Steve Dickson <SteveD@redhat.com> wrote:
> On 02/22/2010 01:33 PM, Andrew Pollock wrote:
>> This is a continuation of commit 09c7ad1cd9c5ca2fc46631a0057d47309abc8706,
>> adding a couple more cases that can spam syslog
>> ---
>>  utils/gssd/gss_util.c  |    2 +-
>>  utils/gssd/gssd_proc.c |    6 +++---
>>  2 files changed, 4 insertions(+), 4 deletions(-)
>> diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
>> index 99aceb3..64dddf1 100644
>> --- a/utils/gssd/gss_util.c
>> +++ b/utils/gssd/gss_util.c
>> @@ -126,7 +126,7 @@ display_status_1(char *m, u_int32_t code, int
>> type, const gss_OID mech)
>>   "gss_display_status called from %s\n", m);
>>   break;
>>   } else {
>> - printerr(0, "ERROR: GSS-API: (%s) error in %s(): %s\n",
>> + printerr(2, "ERROR: GSS-API: (%s) error in %s(): %s\n",
>>      typestr, m, (char *)msg.value);
>>   }
>>
>> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
>> index be4fb11..5629d97 100644
>> --- a/utils/gssd/gssd_proc.c
>> +++ b/utils/gssd/gssd_proc.c
>> @@ -638,7 +638,7 @@ do_error_downcall(int k5_fd, uid_t uid, int err)
>>   unsigned int timeout = 0;
>>   int zero = 0;
>>
>> - printerr(1, "doing error downcall\n");
>> + printerr(2, "doing error downcall\n");
>>
>>   if (WRITE_BYTES(&p, end, uid)) goto out_err;
>>   if (WRITE_BYTES(&p, end, timeout)) goto out_err;
>> @@ -906,7 +906,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t
>> uid, int fd, char *tgtname,
>>   int create_resp = -1;
>>   int err, downcall_err = -EACCES;
>>
>> - printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
>> + printerr(2, "handling krb5 upcall (%s)\n", clp->dirname);
>>
>>   if (tgtname) {
>>   if (clp->servicename) {
>> @@ -1066,7 +1066,7 @@ process_spkm3_upcall(struct clnt_info *clp,
>> uid_t uid, int fd)
>>   }
>>
>>   if (!authgss_get_private_data(auth, &pd)) {
>> - printerr(0, "WARNING: Failed to obtain authentication "
>> + printerr(2, "WARNING: Failed to obtain authentication "
>>      "data for user with uid %d for server %s\n",
>>   uid, clp->servername);
>>   goto out_return_error;
> The only one I'm concern with is this one. How offend does this pop
> and how are people going know (without a restart) the reason the
> are getting deined access is because of obscure error like the
> gss private data can't be accessed?
>
> steved.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I asked this question before, but don't recall an answer.  Unless you
want to run with "-v" by default, or are depending on a part of the
original patch that decreases the message level, I don't see why these
changes from level 1 to leve2 are required??

K.C.
