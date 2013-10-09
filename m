Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:59981 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042Ab3JISdX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Oct 2013 14:33:23 -0400
Received: by mail-vc0-f179.google.com with SMTP id ht10so821123vcb.38
        for <linux-nfs@vger.kernel.org>; Wed, 09 Oct 2013 11:33:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131009162838.GA29734@pad.fieldses.org>
References: <20130930183926.GB6931@two.firstfloor.org>
	<20131004031643.GA13502@two.firstfloor.org>
	<20131004062915.48772e4b@tlielax.poochiereds.net>
	<DD6C34BD-1F21-4355-BE73-56538E5B29D4@netapp.com>
	<20131007131237.GA20881@pad.fieldses.org>
	<20131008222029.GP6882@two.firstfloor.org>
	<20131009162838.GA29734@pad.fieldses.org>
Date: Wed, 9 Oct 2013 14:33:22 -0400
Message-ID: <CAHVgHyVXeDPr8vEN=pQz3-1ZH7=f8ouNvWOmxpUV0Lg_8tGP=w@mail.gmail.com>
Subject: Re: unread variables in sunrpc kerberos code
From: Andy Adamson <androsadamson@gmail.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Coffman Kevin <kwc@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPCSEC_GSS requires that the GSS-API level sequencing is turned off -
e.g. the sequence_req_flag is set to false.

rfc2203:

  When GSS_Init_sec_context() is called, the parameters
  replay_det_req_flag and sequence_req_flag must be turned off. The
  reasons for this are:

  *    ONC RPC can be used over unreliable transports and provides no
        layer to reliably re-assemble messages. Thus it is possible for
        gaps in message sequencing to occur, as well as out of order
        messages.

   *    RPC servers can be multi-threaded, and thus the order in which
        GSS-API messages are signed or wrapped can be different from the
        order in which the messages are verified or unwrapped, even if
        the requests are sent on reliable transports.

   *    To maximize convenience of implementation, the order in which an
        ONC RPC entity will verify the header and verify/unwrap the body
        of an RPC call or reply is left unspecified.

   The RPCSEC_GSS protocol provides for protection from replay attack,
   yet tolerates out-of-order delivery or processing of messages and
   tolerates dropped requests.


So the RPCSEC_GSS layer does the sequencing, not the GSS layer.

-->Andy

On Wed, Oct 9, 2013 at 12:28 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> Adding the linux-nfs list on the cc in case somebody else has looked at
> this more recently than me....
>
> On Wed, Oct 09, 2013 at 12:20:29AM +0200, Andi Kleen wrote:
>> > I think it's probably harmless, though it wouldn't be a bad idea to
>> > review it if somebody had the time.
>>
>> Can you explain why it is harmless? Is the sequence number
>> checked elsewhere? If yes, where?
>
> I really don't remember.
>
> OK, I give in, I'll go look:
>
> RFC 1964 section 1.2.1.2 says
>
>         The sequence number provides a basis for detection of replayed
>         tokens.  Replay detection *can* be performed using state
>         information retained on received sequence numbers...
>
> (emphasis mine), and
>
>         Provision of per-message replay and out-of-sequence detection
>         services is optional for implementation of the Kerberos V5
>         GSS-API mechanism.
>
> For some reason RFC 4121, which appears to be the one describing the v2
> tokens, doesn't have similar text that I can find.  I can't tell what
> they think you're supposed to do with sequence numbers, if anything.
>
> RPC's (hence gss tokens) can be processed out of order, so it's a little
> unclear how the sequence numbers would be checked.  You'd have to choose
> a window of sequence numbers to track, I guess, and just reject anything
> older.  Absence any guidance about how to do this in the RFC's this
> sounds like a potential source of interoperability problems.
>
> RPCSEC_GSS also has its own sequence number that's included in all the
> data we encrypt or checksum, so should provide sufficient replay
> protection on its own.  And the RPCSEC_GSS RPC's do tell you how to
> determine the window and handle old tokens.
>
> So I may be missing something--more review always welcomed--but I think
> it's all OK.
>
> Unless someone else has more to add I'll cook up a patch that attempts
> to make the situation clearer to future unfortunate readers of this
> code.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
