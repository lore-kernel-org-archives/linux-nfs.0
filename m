Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail209.messagelabs.com ([216.82.255.3]:52827 "EHLO
	mail209.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755610Ab2BOAeW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Feb 2012 19:34:22 -0500
Message-ID: <4F3AFD84.3020709@nexenta.com>
Date: Wed, 15 Feb 2012 04:34:12 +0400
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com> <1329259606.11759.15.camel@lade.trondhjem.org>
In-Reply-To: <1329259606.11759.15.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/15/2012 02:46 AM, Myklebust, Trond wrote:
> Hi Vitaliy.
>
> What's wrong with sa_sequenceid == 0? I can't see anything in the spec
> that states that the sequenceid is supposed to be initialised to 1.

That is good question.

  In 2.10.6.1.  "Slot Identifiers and Reply Cache":


    A slot contains a sequence ID and the cached reply corresponding to
    the request sent with that sequence ID.  The sequence ID is a 32-bit
    unsigned value, and is therefore in the range 0..0xFFFFFFFF (2^32 -
    1).  The first time a slot is used, the requester MUST specify a
    sequence ID of one (Section 18.36).


  In 18.36.4.4 "Session creation":

        For each slot in the reply cache, the
        server sets the sequence ID to zero, and records an entry
                                    ^^^^^^^^^

       containing a COMPOUND reply with zero operations and the error
        NFS4ERR_SEQ_MISORDERED.  This way, if the first SEQUENCE request
        sent has a sequence ID equal to zero, the server can simply
                                  ^^^^^^^^^^^^

        return what is in the reply cache: NFS4ERR_SEQ_MISORDERED.  The
        client initializes its reply cache for receiving callbacks in the
        same way, and similarly, the first CB_SEQUENCE operation on a
        slot after session creation MUST have a sequence ID of one.


So sending "zero" sa_sequenceid is allowed.
But if Linux NFS server receives first OP_SEQUENCE with "sa_sequenceid 
== 0", it replies "NFS4ERR_RETRY_UNCACHED_REP"  (for OP_PUTROOTFH) - but 
expected SEQ_MISORDERED for OP_SEQUENCE.  Illumos NFSv4.1 implementation 
returns allowed SEQ_MISORDERED.

So why just do not fix receiving error and correct sending sa_sequenceid 
to 1?
