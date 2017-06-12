Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:33712 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752238AbdFLFDf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jun 2017 01:03:35 -0400
MIME-Version: 1.0
In-Reply-To: <CAO1O6see6yDr-hDVNPi9Kv9wO6p-98w7YhsnnwnVOVCSEGVksw@mail.gmail.com>
References: <20170610025912.6499-1-Jason@zx2c4.com> <878tkzq6wi.fsf@purkki.adurom.net>
 <CAGXu5jKp=X7-eKo+HgzS3uqncx5yy-u=tJNqV9K8GOgJ=-C7iA@mail.gmail.com>
 <CANUX_P2b0Bx+-E_OBQ0reGW0=d6819qc=r83K0kTv0xMo8mtLQ@mail.gmail.com> <CAO1O6see6yDr-hDVNPi9Kv9wO6p-98w7YhsnnwnVOVCSEGVksw@mail.gmail.com>
From: Emmanuel Grumbach <egrumbach@gmail.com>
Date: Mon, 12 Jun 2017 08:03:33 +0300
Message-ID: <CANUX_P1n0=rK+biS7M0-vxP5Uhk5rU+qj4_9jtdRF9Yh219PVA@mail.gmail.com>
Subject: Re: [PATCH 0/6] Constant Time Memory Comparisons Are Important
To: Emil Lenngren <emil.lenngren@gmail.com>
Cc: Kees Cook <keescook@chromium.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        David Howells <dhowells@redhat.com>,
        David Safford <safford@us.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Gilad Ben-Yossef <gilad@benyossef.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        keyrings@vger.kernel.org,
        Bluez mailing list <linux-bluetooth@vger.kernel.org>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 12, 2017 at 12:30 AM, Emil Lenngren <emil.lenngren@gmail.com> wrote:
> 2017-06-11 22:48 GMT+02:00 Emmanuel Grumbach <egrumbach@gmail.com>:
>> On Sun, Jun 11, 2017 at 4:36 PM, Kees Cook <keescook@chromium.org> wrote:
>>>
>>> On Sun, Jun 11, 2017 at 1:13 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
>>> > "Jason A. Donenfeld" <Jason@zx2c4.com> writes:
>>> >
>>> >> Whenever you're comparing two MACs, it's important to do this using
>>> >> crypto_memneq instead of memcmp. With memcmp, you leak timing information,
>>> >> which could then be used to iteratively forge a MAC.
>>> >
>>> > Do you have any pointers where I could learn more about this?
>>>
>>> While not using C specifically, this talks about the problem generally:
>>> https://www.chosenplaintext.ca/articles/beginners-guide-constant-time-cryptography.html
>>>
>>
>> Sorry for the stupid question, but the MAC address is in plaintext in
>> the air anyway or easily accessible via user space tools. I fail to
>> see what it is so secret about a MAC address in that code where that
>> same MAC address is accessible via myriads of ways.
>
> I think you're mixing up Media Access Control (MAC) addresses with
> Message Authentication Code (MAC). The second one is a cryptographic
> signature of a message.

Obviously... Sorry for the noise.
