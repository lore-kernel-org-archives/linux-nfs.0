Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27009 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423099AbdKRSHy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Nov 2017 13:07:54 -0500
Subject: Re: Commit fcd8843c40 breaks old compilers
To: Trond Myklebust <trondmy@primarydata.com>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <09a3d9ca-d191-5899-613d-8d0dbe0b68ea@oracle.com>
 <1511026783.10238.2.camel@primarydata.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <49fec52f-229a-4657-a80d-d1a40a9d38e4@oracle.com>
Date: Sat, 18 Nov 2017 13:07:38 -0500
MIME-Version: 1.0
In-Reply-To: <1511026783.10238.2.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/18/2017 12:39 PM, Trond Myklebust wrote:
> On Sat, 2017-11-18 at 12:19 -0500, Boris Ostrovsky wrote:
>> Commit fcd8843c406b46433857ae45e5e9d84b01a7d20b breaks on older
>> compilers which cannot process initializers for anonymous structures:
>>
>> +const nfs4_stateid invalid_stateid = {
>> +       {
>> +               .seqid = cpu_to_be32(0xffffffffU),
>> +               .other = { 0 },
>> +       },
>> +       .type = NFS4_INVALID_STATEID_TYPE,
>> +};
>>
>>
>> /home/build/linux-linus/fs/nfs/nfs4state.c:74: error: unknown field
>> ‘seqid’ specified in initializer
>> /home/build/linux-linus/fs/nfs/nfs4state.c:74: warning: missing
>> braces
>> around initializer
>> /home/build/linux-linus/fs/nfs/nfs4state.c:74: warning: (near
>> initialization for ‘invalid_stateid.<anonymous>.data’)
>> /home/build/linux-linus/fs/nfs/nfs4state.c:74: warning: overflow in
>> implicit constant conversion
>> /home/build/linux-linus/fs/nfs/nfs4state.c:75: error: unknown field
>> ‘other’ specified in initializer
>> /home/build/linux-linus/fs/nfs/nfs4state.c:75: error: extra brace
>> group
>> at end of initializer
>> /home/build/linux-linus/fs/nfs/nfs4state.c:75: error: (near
>> initialization for ‘invalid_stateid.<anonymous>’)
>> /home/build/linux-linus/fs/nfs/nfs4state.c:75: warning: excess
>> elements
>> in union initializer
>> /home/build/linux-linus/fs/nfs/nfs4state.c:75: warning: (near
>> initialization for ‘invalid_stateid.<anonymous>’)
>> make[4]: *** [fs/nfs/nfs4state.o] Error 1
>> make[3]: *** [fs/nfs] Error 2
>>
>>
>> FC-64 <build@build-mk2:~> gcc --version
>> gcc (GCC) 4.4.4 20100503 (Red Hat 4.4.4-2)
>>
>>
>> A similar bug was fixed by e0714ec4f9efe7b86828b0dcc077fd8f5d8e5e91
>> but
>> I don't think the same approach can work here.
> 
> 
> I don't have any setups with gcc 4.4.4. What is it expecting here? Is
> it expecting an extra set of braces due to the anonymous "struct"?
> 

No, that won't work (at least I couldn't get it to work) because the 
solution from e0714ec4f9e assumes that the anonymous struct is the first 
one in the enveloping struct.

It worked only if I (this is a small C program with equivalent structs):

struct nfs4_stateid_struct {
         union {
                 //char data[4];
                 struct {
                         unsigned seqid;
                         char other[6];
                 } __attribute__ ((packed));
		char data[4];
         };
and then

const nfs4_stateid invalid_stateid = {
         {
                   {.seqid = 0xffffffffU,
                   .other = { 0 } },
         },
         .type = NFS4_INVALID_STATEID_TYPE,
};

If I keep data[4] where it is now I get compiler error

an.c:35:20: error: field name not in record or union initializer
                    {.seqid = 0xffffffffU,
                     ^
an.c:35:20: note: (near initialization for 
'invalid_stateid.<anonymous>.data')
an.c:35:29: warning: overflow in implicit constant conversion [-Woverflow]
                    {.seqid = 0xffffffffU,
                              ^~~~~~~~~~~
an.c:36:19: error: field name not in record or union initializer
                    .other = { 0 } },
                    ^
an.c:36:19: note: (near initialization for 
'invalid_stateid.<anonymous>.data')
an.c:36:19: warning: braces around scalar initializer
an.c:36:19: note: (near initialization for 
'invalid_stateid.<anonymous>.data[1]')

I don't know if you want to change public header file just to get around 
this problem.


-boris
