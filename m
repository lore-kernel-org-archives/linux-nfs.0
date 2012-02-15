Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:65509 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab2BOPpj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 10:45:39 -0500
Received: by werb13 with SMTP id b13so705900wer.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 07:45:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329319793.3364.9.camel@lade.trondhjem.org>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
	<1329259606.11759.15.camel@lade.trondhjem.org>
	<4F3AFD84.3020709@nexenta.com>
	<1329266587.28837.4.camel@lade.trondhjem.org>
	<20120215005315.GA9018@fieldses.org>
	<1329270628.28837.15.camel@lade.trondhjem.org>
	<0C12B635-0094-4099-B96C-3637B914A814@netapp.com>
	<1329319793.3364.9.camel@lade.trondhjem.org>
Date: Wed, 15 Feb 2012 10:45:37 -0500
Message-ID: <CAHVgHyW9CoPjZNvy4EdSknScM_K00QmwavG=RdsBTSmjVvT_3g@mail.gmail.com>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 15, 2012 at 10:29 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-02-15 at 15:01 +0000, Adamson, Andy wrote:
>> On Feb 14, 2012, at 8:50 PM, Myklebust, Trond wrote:
>>
>> > On Tue, 2012-02-14 at 19:53 -0500, J. Bruce Fields wrote:
>> >> On Wed, Feb 15, 2012 at 12:43:08AM +0000, Myklebust, Trond wrote:
>> >>> Then we have a problem. The zero initialisation is already in use out
>> >>> there in both commercial and non-commercial versions of Linux. It is too
>> >>> late to change that now.
>> >>>
>> >>> Furthermore, since none of the servers we've tested against in earlier
>> >>> Bakeathons and Connectathons have complained, I suggest that we rather
>> >>> change the spec with an errata.
>> >>
>> >> Argh.
>> >>
>> >> I just noticed that the server was crashing intermittently and traced it
>> >> to incorrect handling of the case where the client sends a one-op
>> >> SEQUENCE compound with seqid 0.  I'm not sure why it started popping up
>> >> just in 3.3--perhaps some change in the way the client uses slots made
>> >> that more likely.
>> >>
>> >> The server code actually looks like it did assume initial seqid 1, but
>> >> accepted initial seqid 0 (except in this one case) basically by mistake.
>> >>
>> >> In any case, I think it should be easy enough to teach it just to accept
>> >> any seqid on a previously unused slot, so I'll do that....
>> >
>> > Hang on... Looking at 3.2, I think you're correct. We used to initialise
>> > to 1, and now we're initialising to 0.
>>
>> No, commit aacd5537270a752fe12a9914a207284fc2341c6d initializes and resets the slot tables with the ivalue which is 1 for the forechannel and 0 for the back channel, just as in 3.2.
>> To be clear from aacd5537:
>>
>> -static int nfs4_init_slot_tables(struct nfs4_session *session)
>> +static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
>>  {
>>         struct nfs4_slot_table *tbl;
>> -       int status = 0;
>> +       int status;
>>
>> -       tbl = &session->fc_slot_table;
>> +       dprintk("--> %s\n", __func__);
>> +       /* Fore channel */
>> +       tbl = &ses->fc_slot_table;
>>         if (tbl->slots == NULL) {
>> -               status = nfs4_init_slot_table(tbl,
>> -                               session->fc_attrs.max_reqs, 1);
>>                                                                              ^^^^^^^
>>                                                                              ivalue of 1
>>
>> +               status = nfs4_init_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
>>                                                                                                                     ^^^^^
>>                                                                                                                   ivalue of 1
>> +               if (status) /* -ENOMEM */
>> +                       return status;
>> +       } else {
>> +               status = nfs4_reset_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
>>                                                                                                                     ^^^^^
>>                                                                                                                   ivalue of 1
>>                 if (status)
>>                         return status;
>>         }
>> -
>> -       tbl = &session->bc_slot_table;
>> +       /* Back channel */
>> +       tbl = &ses->bc_slot_table;
>>         if (tbl->slots == NULL) {
>> -               status = nfs4_init_slot_table(tbl,
>> -                               session->bc_attrs.max_reqs, 0);
>> +               status = nfs4_init_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
>>                 if (status)
>> -                       nfs4_destroy_slot_tables(session);
>> -       }
>> -
>> +                       /* Fore and back channel share a connection so get
>> +                        * both slot tables or neither */
>> +                       nfs4_destroy_slot_tables(ses);
>> +       } else
>> +               status = nfs4_reset_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
>>         return status;
>>  }
>
> Yes, and it then _removed_ the previously unconditional call to
> nfs4_reset_slot_tables() from nfs4_proc_create_session(). Which means
> that the tbl->slots == NULL path no longer initialises the slot table
> sequence numbers.


Ah - you are correct. nfs4_setup_session_slot_tables is called and
incorrectly assumed that nfs4_init_slot_tables actually initialized
the slots, which it doesn't and is  a bug.

For my 2 cents: I like Vitilay's inthinkitial patch.

-->Andy

> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
