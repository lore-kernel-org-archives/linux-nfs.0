Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:33155 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752076AbeENR0S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2018 13:26:18 -0400
Received: by mail-vk0-f46.google.com with SMTP id q189-v6so8006474vkb.0
        for <linux-nfs@vger.kernel.org>; Mon, 14 May 2018 10:26:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2C808B88-619E-4F7C-9817-4937C4A2427B@oracle.com>
References: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
 <CAN-5tyH8i0hmx8nvMUXhndZE_LcGAB0mySjBpDTq7eLQ-gFgiQ@mail.gmail.com>
 <8E0A99E2-7037-4023-99F5-594430919604@oracle.com> <CAN-5tyFQ9vbTHQJ7g4_0sVLCO2ppyTmTcrww5t_SD-x9yg6u5A@mail.gmail.com>
 <7964A589-32F6-4881-9706-775A82C20103@oracle.com> <CAN-5tyEM4NATLAQky2evmyaM06d+vrZf0A5Sw6MggJsWmsVeFw@mail.gmail.com>
 <2C808B88-619E-4F7C-9817-4937C4A2427B@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 14 May 2018 13:26:16 -0400
Message-ID: <CAN-5tyH-WErrT33VYsXVgjkpq35qCen9ZPjc1M73Cec4ipNfsQ@mail.gmail.com>
Subject: Re: SETCLIENTID acceptor
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 11, 2018 at 4:57 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On May 10, 2018, at 4:58 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Thu, May 10, 2018 at 3:23 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>
>>>> On May 10, 2018, at 3:07 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>
>>>> On Thu, May 10, 2018 at 2:09 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>
>>>>>
>>>>>> On May 10, 2018, at 1:40 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>
>>>>>> On Wed, May 9, 2018 at 5:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>> I'm right on the edge of my understanding of how this all works.
>>>>>>>
>>>>>>> I've re-keyed my NFS server. Now on my client, I'm seeing this on
>>>>>>> vers=4.0,sec=sys mounts:
>>>>>>>
>>>>>>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
>>>>>>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
>>>>>>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
>>>>>>>
>>>>>>> manet is my client, and klimt is my server. I'm mounting with
>>>>>>> NFS/RDMA, so I'm mounting hostname klimt.ib, not klimt.
>>>>>>>
>>>>>>> Because the client is using krb5i for lease management, the server
>>>>>>> is required to use krb5i for the callback channel (S 3.3.3 of RFC
>>>>>>> 7530).
>>>>>>>
>>>>>>> After a SETCLIENTID, the client copies the acceptor from the GSS
>>>>>>> context it set up, and uses that to check incoming callback
>>>>>>> requests. I instrumented the client's SETCLIENTID proc, and I see
>>>>>>> this:
>>>>>>>
>>>>>>> check_gss_callback_principal: acceptor=nfs@klimt.ib.1015granger.net, principal=host@klimt.1015granger.net
>>>>>>>
>>>>>>> The principal strings are not equal, and that's why the client
>>>>>>> believes the callback credential is bogus. Now I'm trying to
>>>>>>> figure out whether it is the server's callback client or the
>>>>>>> client's callback server that is misbehaving.
>>>>>>>
>>>>>>> To me, the server's callback principal (host@klimt) seems like it
>>>>>>> is correct. The client would identify as host@manet when making
>>>>>>> calls to the server, for example, so I'd expect the server to
>>>>>>> behave similarly when performing callbacks.
>>>>>>>
>>>>>>> Can anyone shed more light on this?
>>>>>>
>>>>>> What are your full hostnames of each machine and does the reverse
>>>>>> lookup from the ip to hostname on each machine give you what you
>>>>>> expect?
>>>>>>
>>>>>> Sounds like all of them need to be resolved to <>.ib.1015grager.net
>>>>>> but somewhere you are getting <>.1015grager.net instead.
>>>>>
>>>>> The forward and reverse mappings are consistent, and rdns is
>>>>> disabled in my krb5.conf files. My server is multi-homed; it
>>>>> has a 1GbE interface (klimt.1015granger.net); an FDR IB
>>>>> interface (klimt.ib.1015granger.net); and a 25 GbE interface
>>>>> (klimt.roce.1015granger.net).
>>>>
>>>> Ah, so you are keeping it very interesting...
>>>>
>>>>> My theory is that the server needs to use the same principal
>>>>> for callback operations that the client used for lease
>>>>> establishment. The last paragraph of S3.3.3 seems to state
>>>>> that requirement, though it's not especially clear; and the
>>>>> client has required it since commit f11b2a1cfbf5 (2014).
>>>>>
>>>>> So the server should authenticate as nfs@klimt.ib and not
>>>>> host@klimt, in this case, when performing callback requests.
>>>>
>>>> Yes I agree that server should have authenticated as nfs@klmit.ib and
>>>> that's what I see in my (simple) single home setup.
>>>>
>>>> In nfs-utils there is code that deals with the callback and comment
>>>> about choices for the principal:
>>>>        * Restricting gssd to use "nfs" service name is needed for when
>>>>        * the NFS server is doing a callback to the NFS client.  In this
>>>>        * case, the NFS server has to authenticate itself as "nfs" --
>>>>        * even if there are other service keys such as "host" or "root"
>>>>        * in the keytab.
>>>> So the upcall for the callback should have specifically specified
>>>> "nfs" to look for the nfs/<hostname>. Question is if you key tab has
>>>> both:
>>>> nfs/klmit and nfs/klmit.ib how does it choose which one to take. I'm
>>>> not sure. But I guess in your case you are seeing that it choose
>>>> "host/<>" which would really be a nfs-utils bug.
>>>
>>> I think the upcall is correctly requesting an nfs/ principal
>>> (see below).
>>>
>>> Not only does it need to choose an nfs/ principal, but it also
>>> has to pick the correct domain name. The domain name does not
>>> seem to be passed up to gssd. fs/nfsd/nfs4state.c has this:
>>>
>>> 749 static struct rpc_cred *callback_cred;
>>> 750
>>> 751 int set_callback_cred(void)
>>> 752 {
>>> 753         if (callback_cred)
>>> 754                 return 0;
>>> 755         callback_cred = rpc_lookup_machine_cred("nfs");
>>> 756         if (!callback_cred)
>>> 757                 return -ENOMEM;
>>> 758         return 0;
>>> 759 }
>>> 760
>>> 761 void cleanup_callback_cred(void)
>>> 762 {
>>> 763         if (callback_cred) {
>>> 764                 put_rpccred(callback_cred);
>>> 765                 callback_cred = NULL;
>>> 766         }
>>> 767 }
>>> 768
>>> 769 static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc_clnt *client, struct nfsd4_session *ses)
>>> 770 {
>>> 771         if (clp->cl_minorversion == 0) {
>>> 772                 return get_rpccred(callback_cred);
>>> 773         } else {
>>> 774                 struct rpc_auth *auth = client->cl_auth;
>>> 775                 struct auth_cred acred = {};
>>> 776
>>> 777                 acred.uid = ses->se_cb_sec.uid;
>>> 778                 acred.gid = ses->se_cb_sec.gid;
>>> 779                 return auth->au_ops->lookup_cred(client->cl_auth, &acred, 0);
>>> 780         }
>>> 781 }
>>>
>>> rpc_lookup_machine_cred("nfs"); should request an "nfs/" service
>>> principal, shouldn't it?
>>>
>>> Though I think this approach is incorrect. The server should not
>>> use the machine cred here, it should use a credential based on
>>> the principal the client used to establish it's lease.
>>>
>>>
>>>> What's in your server's key tab?
>>>
>>> [root@klimt ~]# klist -ke /etc/krb5.keytab
>>> Keytab name: FILE:/etc/krb5.keytab
>>> KVNO Principal
>>> ---- --------------------------------------------------------------------------
>>>   4 host/klimt.1015granger.net@1015GRANGER.NET (aes256-cts-hmac-sha1-96)
>>>   4 host/klimt.1015granger.net@1015GRANGER.NET (aes128-cts-hmac-sha1-96)
>>>   4 host/klimt.1015granger.net@1015GRANGER.NET (des3-cbc-sha1)
>>>   4 host/klimt.1015granger.net@1015GRANGER.NET (arcfour-hmac)
>>>   3 nfs/klimt.1015granger.net@1015GRANGER.NET (aes256-cts-hmac-sha1-96)
>>>   3 nfs/klimt.1015granger.net@1015GRANGER.NET (aes128-cts-hmac-sha1-96)
>>>   3 nfs/klimt.1015granger.net@1015GRANGER.NET (des3-cbc-sha1)
>>>   3 nfs/klimt.1015granger.net@1015GRANGER.NET (arcfour-hmac)
>>>   3 nfs/klimt.ib.1015granger.net@1015GRANGER.NET (aes256-cts-hmac-sha1-96)
>>>   3 nfs/klimt.ib.1015granger.net@1015GRANGER.NET (aes128-cts-hmac-sha1-96)
>>>   3 nfs/klimt.ib.1015granger.net@1015GRANGER.NET (des3-cbc-sha1)
>>>   3 nfs/klimt.ib.1015granger.net@1015GRANGER.NET (arcfour-hmac)
>>>   3 nfs/klimt.roce.1015granger.net@1015GRANGER.NET (aes256-cts-hmac-sha1-96)
>>>   3 nfs/klimt.roce.1015granger.net@1015GRANGER.NET (aes128-cts-hmac-sha1-96)
>>>   3 nfs/klimt.roce.1015granger.net@1015GRANGER.NET (des3-cbc-sha1)
>>>   3 nfs/klimt.roce.1015granger.net@1015GRANGER.NET (arcfour-hmac)
>>> [root@klimt ~]#
>>>
>>> As a workaround, I bet moving the keys for nfs/klimt.ib to
>>> the front of the keytab file would allow Kerberos to work
>>> with the klimt.ib interface.
>>>
>>>
>>>> An output from gssd -vvv would be interesting.
>>>
>>> May 10 14:43:24 klimt rpc.gssd[1191]: #012handle_gssd_upcall: 'mech=krb5 uid=0 target=host@manet.1015granger.net service=nfs enctypes=18,17,16,2
>>> 3,3,1,2 ' (nfsd4_cb/clnt0)
>>> May 10 14:43:24 klimt rpc.gssd[1191]: krb5_use_machine_creds: uid 0 tgtname host@manet.1015granger.net
>>> May 10 14:43:24 klimt rpc.gssd[1191]: Full hostname for 'manet.1015granger.net' is 'manet.1015granger.net'
>>> May 10 14:43:24 klimt rpc.gssd[1191]: Full hostname for 'klimt.1015granger.net' is 'klimt.1015granger.net'
>>
>> I think that's the problem. This should have been
>> klimt.ib.1015granger.net. nfs-utils just calls gethostname() to get
>> the local domain name. And this is what it'll match against the key
>> tab entry. So I think even if you move the key tabs around it probably
>> will still pick nfs@klmit.1015granger.net.
>
> mount.nfs has a helper function called nfs_ca_sockname() that does a
> connect/getsockname dance to derive the local host's hostname as it
> is seen by the other end of the connection. So in this case, the
> server's gssd would get the client's name, "manet.ib.1015granger.net"
> and the "nfs" service name, and would correctly derive the service
> principal "nfs/klimt.ib.1015granger.net" based on that.
>
> Would it work if gssd did this instead of using gethostname(3) ? Then
> the kernel wouldn't have to pass the correct principal up to gssd, it
> would be able to derive it by itself.

I'd need to remind myself of how all of this work because I could
confidently answer this. We are currently passing "target=" from the
kernel as well as doing gethostbyname() in the gssd. Why? I don't know
and need to figure out what each piece really accomplishes.

I would think if the kernel could provide us with the correct domain
name (as it knows over which interface the request came in), then gssd
should just be using that instead querying the domain on its own.

Btw, what happened after your turned off the gssproxy? Did you get
further in getting the "nfs" and not "host" identity used?
