Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f176.google.com ([209.85.217.176]:36570 "EHLO
        mail-ua0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751228AbeEKUET (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2018 16:04:19 -0400
Received: by mail-ua0-f176.google.com with SMTP id b25-v6so4390214uak.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 May 2018 13:04:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <04280BD8-1922-44BD-899B-E5BBCB980D87@oracle.com>
References: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
 <CAN-5tyH8i0hmx8nvMUXhndZE_LcGAB0mySjBpDTq7eLQ-gFgiQ@mail.gmail.com>
 <8E0A99E2-7037-4023-99F5-594430919604@oracle.com> <CAN-5tyFQ9vbTHQJ7g4_0sVLCO2ppyTmTcrww5t_SD-x9yg6u5A@mail.gmail.com>
 <7964A589-32F6-4881-9706-775A82C20103@oracle.com> <CAN-5tyEM4NATLAQky2evmyaM06d+vrZf0A5Sw6MggJsWmsVeFw@mail.gmail.com>
 <95A4EAAC-1A7D-4161-B63C-93B62D8ADC60@oracle.com> <CAN-5tyGz2e6W6fP1_QiUj-aM5ozymykGTZ7XH7DO5xF=_ERSbw@mail.gmail.com>
 <FF5BFD75-3464-4217-9B8C-5244BA9E53D5@oracle.com> <04280BD8-1922-44BD-899B-E5BBCB980D87@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 11 May 2018 16:04:17 -0400
Message-ID: <CAN-5tyHFN5K0eA0gv5oKuB1CG7kc+4rGzFsi-FenGS+fOizgPQ@mail.gmail.com>
Subject: Re: SETCLIENTID acceptor
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 11, 2018 at 3:43 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On May 11, 2018, at 10:34 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>
>>
>>> On May 10, 2018, at 5:34 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>
>>> On Thu, May 10, 2018 at 5:11 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>
>>>>
>>>>> On May 10, 2018, at 4:58 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>
>>>>> On Thu, May 10, 2018 at 3:23 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>> May 10 14:43:24 klimt rpc.gssd[1191]: Success getting keytab entry for 'nfs/klimt.1015granger.net@1015GRANGER.NET'
>>>>>> May 10 14:43:24 klimt rpc.gssd[1191]: gssd_get_single_krb5_cred: principal 'nfs/klimt.1015granger.net@1015GRANGER.NET' ccache:'FILE:/tmp/krb5ccmachine_1015GRANGER.NET'
>>>>>> May 10 14:43:24 klimt rpc.gssd[1191]: INFO: Credentials in CC 'FILE:/tmp/krb5ccmachine_1015GRANGER.NET' are good until 1526064204
>>>>>> May 10 14:43:24 klimt rpc.gssd[1191]: creating tcp client for server manet.1015granger.net
>>>>>> May 10 14:43:24 klimt rpc.gssd[1191]: creating context with server host@manet.1015granger.net
>>>>>> May 10 14:43:24 klimt rpc.gssd[1191]: doing downcall: lifetime_rec=76170 acceptor=host@manet.1015granger.net
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: #012handle_gssd_upcall: 'mech=krb5 uid=0 target=host@manet.1015granger.net service=nfs enctypes=18,17,16,23,3,1,2 ' (nfsd4_cb/clnt1)
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: krb5_use_machine_creds: uid 0 tgtname host@manet.1015granger.net
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: Full hostname for 'manet.1015granger.net' is 'manet.1015granger.net'
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: Full hostname for 'klimt.1015granger.net' is 'klimt.1015granger.net'
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: Success getting keytab entry for 'nfs/klimt.1015granger.net@1015GRANGER.NET'
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: INFO: Credentials in CC 'FILE:/tmp/krb5ccmachine_1015GRANGER.NET' are good until 1526064204
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: INFO: Credentials in CC 'FILE:/tmp/krb5ccmachine_1015GRANGER.NET' are good until 1526064204
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: creating tcp client for server manet.1015granger.net
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: creating context with server host@manet.1015granger.net
>>>>>> May 10 14:44:31 klimt rpc.gssd[1191]: doing downcall: lifetime_rec=76103 acceptor=host@manet.1015granger.net
>>>>>
>>>>> Going back to the original mail where you wrote:
>>>>>
>>>>> check_gss_callback_principal: acceptor=nfs@klimt.ib.1015granger.net,
>>>>> principal=host@klimt.1015granger.net
>>>>>
>>>>> Where is this output on the client kernel or server kernel?
>>>>>
>>>>> According to the gssd output. In the callback authentication
>>>>> nfs@klimt.1015granger.net is authenticating to
>>>>> host@manet.1015granger.net. None of them match the
>>>>> "check_gss_callback_principal" output. So I'm confused...
>>>>
>>>> This is instrumentation I added to the check_gss_callback_principal
>>>> function on the client. The above is gssd output on the server.
>>>>
>>>> The client seems to be checking the acceptor (nfs@klimt.ib) of
>>>> the forward channel GSS context against the principal the server
>>>> actually uses (host@klimt) to establish the backchannel GSS
>>>> context.
>>>>
>>>
>>> But according to the gssd output on the server, the server uses
>>> 'nfs/klimt.1015granger.net@1015GRANGER.NET' not "host@klimt" as the
>>> principal.
>>> So if that output would have been a difference but only in the domain,
>>> then that would be matching my understanding.
>>
>> I can't even get this to work with NFS/TCP on klimt.1015granger.net,
>> and a single "nfs/klimt.1015granger.net" entry in the server's keytab.
>> The client complains the server is using "host@klimt.1015granger.net"
>> as the callback principal.
>>
>> I'm looking into it.
>
> It appears that gssproxy caches the credential on persistent storage.
> See /var/lib/gssproxy/clients/*

gssproxy has given me so many problems. I always turn it off.
