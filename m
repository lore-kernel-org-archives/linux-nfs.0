Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:34983 "EHLO
        mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967268AbeEYQrJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 May 2018 12:47:09 -0400
Received: by mail-vk0-f49.google.com with SMTP id g72-v6so3521946vke.2
        for <linux-nfs@vger.kernel.org>; Fri, 25 May 2018 09:47:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHXpp1DgX4ULnnWmUoyPHFUOVWR0PiMhhaD89Gxn9Hf-g@mail.gmail.com>
References: <20180524200542.22685-1-kolga@netapp.com> <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
 <CAN-5tyHb4WDXqqeYxQm+kzjmSquaKZ3fqsVkMW1Hx5RCmdxb2Q@mail.gmail.com>
 <63AA3A00-6272-4D91-AC0A-30C9A169DBD1@oracle.com> <CAN-5tyHXpp1DgX4ULnnWmUoyPHFUOVWR0PiMhhaD89Gxn9Hf-g@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 25 May 2018 12:47:07 -0400
Message-ID: <CAN-5tyEUSXFJjjivkuYOrA+FFqSYrvcj7SomTSE2Zk8C_6GYYg@mail.gmail.com>
Subject: Re: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 25, 2018 at 12:44 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Fri, May 25, 2018 at 12:24 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Hi Olga-
>>
>>> On May 25, 2018, at 7:02 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>
>>> Thank you for the comments. Will hopefully address them in the next version.
>>>
>>> On Thu, May 24, 2018 at 8:50 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> Hi Olga-
>>>>
>>>>> On May 24, 2018, at 1:05 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>>>>
>>>>> If the user supplies a clientaddr value,
>>>>
>>>> Please say "NFS client administrator" not "user". A
>>>> "user" is any non-privileged user, so saying that a
>>>> "user" can set this value is misleading.
>>>
>>> Ok will change it.
>>>
>>>>> it should be either
>>>>> a special value of either IPV4/IPV6 any address or a local address
>>>>> on the same network that the server being mounted.
>>>>
>>>> This option should allow any local address the client has,
>>>> not just an address that is on the same network as the
>>>> server. See below for further explanation.
>>>
>>> Ok, I added this to the comment specifically as I didn't know if this
>>> would pose a problem. I didn't know if allowing any address was useful
>>> as when it's not specified the address on the same network as the
>>> server is chosen.
>>
>> Yep, any of the client's local addresses should be allowed.
>>
>>
>>>>> Otherwise, we
>>>>> disallow the client to use an arbitrary value of the clientaddr value.
>>>>> This value is used to construct a client id of SETCLIENTID and
>>>>> providing a false value can interfere with the real owner's mount.
>>>>
>>>> The patch description is misleading:
>>>>
>>>> Interference occurs only if the real owner's lease is
>>>> not protected by Kerberos AND this client has the same
>>>> client ID string as another client.
>>>
>>> Ok I will add this more explicit detail when the interference occurs
>>> (when neither of the machines are using Kerberos and the other client
>>> machine is not using a module parameter to add a unique identifier to
>>> the client ID string). I think otherwise it is knowns that client ID
>>> is created with the value of the clientaddr.
>>
>> The only way a problem occurs is if the clientaddr is the
>> same AND the cl_nodename is the same. How is that happening?
>
> Client ID in the SETCLIENTID is constructed by
> nfs4_init_nonuniform_client_string() function and it uses cl_ipaddr
> and not cl_nodename.
>
>> Why are the cl_nodenames the same? If they are not the same,
>> then it is not possible that the clients' leases are inter-
>> fering with each other, and something else is going on.
>>
>>
>>>> The Linux client's client ID string also contains the
>>>> system's cl_nodename. Both the cl_nodename and the
>>>> callback address have to be the same as some other
>>>> client's, and they both have to be Linux, for this to
>>>> be a problem.
>>>>
>>>> It's more likely that the customer's clients are all
>>>> named the same (maybe they are copied from the same
>>>> system image), and reverse DNS lookup is giving them
>>>> all the same clientaddr= . That's an unsupported
>>>> configuration and there are already ways to address
>>>> this.
>>>>
>>>> Or perhaps I don't understand the use case that is
>>>> causing the problem. Can the patch description explain
>>>> why your customer is trying to set clientaddr= ?
>>>
>>> The customer case was a simple mistake of including the wrong address.
>>
>> But that doesn't answer the question. Why did the
>> customer feel the need to set clientaddr= ?
>
> I don't know. In the end they decided they didn't need the clientaddr at all.
>
>>> Do you fundamentally disagree that there is a case for
>>> denial-of-service here?
>>
>> The only service that is affected if the clientaddr is

Forgot to address this. This is definitely not true. Both clients are
effected as they end up "sharing" the lease. So each client once it
gets a lease error has to go and renegotiate the lease and can perhaps
get an operation in before the other client will send something which
would then get and error and it would deals with the lease error.

>> set incorrectly is on the client where the mistake
>> occurs. If the cl_nodenames are all unique then other
>> clients should not be affected by the mistake. If
>> that is happening, that's a server bug.
>>
>> If the problem was that the customer set the wrong
>> address, let's say that, rather than claiming that the
>> patch prevents lease tampering.
>
> Ok I can change it to lease tampering (I really don't care that much).
> But to just to discuss a bit further, how's lease tampering not a
> denial-of-service? It interfere with a client's ability to make
> progress.
>
>>
>>
>> --
>> Chuck Lever
>>
>>
>>
