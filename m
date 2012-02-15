Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58906 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab2BOPQw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 10:16:52 -0500
Received: by wgbdt10 with SMTP id dt10so1034228wgb.1
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 07:16:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F3BC9F6.90409@nexenta.com>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
	<1329259606.11759.15.camel@lade.trondhjem.org>
	<4F3AFD84.3020709@nexenta.com>
	<1329266587.28837.4.camel@lade.trondhjem.org>
	<20120215005315.GA9018@fieldses.org>
	<1329270628.28837.15.camel@lade.trondhjem.org>
	<0C12B635-0094-4099-B96C-3637B914A814@netapp.com>
	<4F3BC9F6.90409@nexenta.com>
Date: Wed, 15 Feb 2012 10:16:50 -0500
Message-ID: <CAHVgHyXaAQvngPMrv+NaOKvKauHaqWJJbjqciJCOtJwYuSKVow@mail.gmail.com>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
From: Andy Adamson <androsadamson@gmail.com>
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 15, 2012 at 10:06 AM, Vitaliy Gusev
<gusev.vitaliy@nexenta.com> wrote:
> On 02/15/2012 07:01 PM, Adamson, Andy wrote:
>>
>>
>> No, commit aacd5537270a752fe12a9914a207284fc2341c6d initializes and resets
>> the slot tables with the ivalue
>> which is 1 for the forechannel and 0 for the back channel, just as in 3.2.
>
>
>
> nfs4_init_slot_table() doesn't use ivalue at all.

Yep - that is the bug - which is in v2.6.39, and v3.2 ....

-->Andy
>
>
>
>>
>> To be clear from aacd5537:
>>
>> -static int nfs4_init_slot_tables(struct nfs4_session *session)
>> +static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
>>  {
>>         struct nfs4_slot_table *tbl;
>> -       int status = 0;
>> +       int status;
>>
>> -       tbl =&session->fc_slot_table;
>>
>> +       dprintk("-->  %s\n", __func__);
>> +       /* Fore channel */
>> +       tbl =&ses->fc_slot_table;
>>
>>         if (tbl->slots == NULL) {
>> -               status = nfs4_init_slot_table(tbl,
>> -                               session->fc_attrs.max_reqs, 1);
>>
>>    ^^^^^^^
>>
>>    ivalue of 1
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
