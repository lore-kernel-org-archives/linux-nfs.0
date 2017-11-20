Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36599 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdKTMw2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Nov 2017 07:52:28 -0500
MIME-Version: 1.0
In-Reply-To: <49fec52f-229a-4657-a80d-d1a40a9d38e4@oracle.com>
References: <09a3d9ca-d191-5899-613d-8d0dbe0b68ea@oracle.com>
 <1511026783.10238.2.camel@primarydata.com> <49fec52f-229a-4657-a80d-d1a40a9d38e4@oracle.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 20 Nov 2017 13:52:27 +0100
Message-ID: <CAK8P3a3uvP17F17eiVziJQ+KVNL5TQ4LwdKbJabFo0iD2oSD5Q@mail.gmail.com>
Subject: Re: Commit fcd8843c40 breaks old compilers
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 18, 2017 at 7:07 PM, Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
>
> On 11/18/2017 12:39 PM, Trond Myklebust wrote:
>>
>> On Sat, 2017-11-18 at 12:19 -0500, Boris Ostrovsky wrote:
>>>

>>> A similar bug was fixed by e0714ec4f9efe7b86828b0dcc077fd8f5d8e5e91
>>> but
>>> I don't think the same approach can work here.
>>
>>
>>
>> I don't have any setups with gcc 4.4.4. What is it expecting here? Is
>> it expecting an extra set of braces due to the anonymous "struct"?

I can reproduce it with gcc-4.5 but not 4.6. We've had similar problems
in the past in other anonymous unions.

> I don't know if you want to change public header file just to get around
> this problem.

I think flipping the two members around should be safe here. It's
not exported to user space, and all other users of that structure
don't care about the order inside of the union.

       Arnd
