Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:59176 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752144AbeEJVLR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 17:11:17 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: SETCLIENTID acceptor
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyEM4NATLAQky2evmyaM06d+vrZf0A5Sw6MggJsWmsVeFw@mail.gmail.com>
Date: Thu, 10 May 2018 17:11:05 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <95A4EAAC-1A7D-4161-B63C-93B62D8ADC60@oracle.com>
References: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
 <CAN-5tyH8i0hmx8nvMUXhndZE_LcGAB0mySjBpDTq7eLQ-gFgiQ@mail.gmail.com>
 <8E0A99E2-7037-4023-99F5-594430919604@oracle.com>
 <CAN-5tyFQ9vbTHQJ7g4_0sVLCO2ppyTmTcrww5t_SD-x9yg6u5A@mail.gmail.com>
 <7964A589-32F6-4881-9706-775A82C20103@oracle.com>
 <CAN-5tyEM4NATLAQky2evmyaM06d+vrZf0A5Sw6MggJsWmsVeFw@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 10, 2018, at 4:58 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Thu, May 10, 2018 at 3:23 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On May 10, 2018, at 3:07 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>=20
>>> On Thu, May 10, 2018 at 2:09 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>=20
>>>>=20
>>>>> On May 10, 2018, at 1:40 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>=20
>>>>> On Wed, May 9, 2018 at 5:19 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>> I'm right on the edge of my understanding of how this all works.
>>>>>>=20
>>>>>> I've re-keyed my NFS server. Now on my client, I'm seeing this on
>>>>>> vers=3D4.0,sec=3Dsys mounts:
>>>>>>=20
>>>>>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains =
invalid cred
>>>>>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains =
invalid cred
>>>>>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains =
invalid cred
>>>>>>=20
>>>>>> manet is my client, and klimt is my server. I'm mounting with
>>>>>> NFS/RDMA, so I'm mounting hostname klimt.ib, not klimt.
>>>>>>=20
>>>>>> Because the client is using krb5i for lease management, the =
server
>>>>>> is required to use krb5i for the callback channel (S 3.3.3 of RFC
>>>>>> 7530).
>>>>>>=20
>>>>>> After a SETCLIENTID, the client copies the acceptor from the GSS
>>>>>> context it set up, and uses that to check incoming callback
>>>>>> requests. I instrumented the client's SETCLIENTID proc, and I see
>>>>>> this:
>>>>>>=20
>>>>>> check_gss_callback_principal: =
acceptor=3Dnfs@klimt.ib.1015granger.net, =
principal=3Dhost@klimt.1015granger.net
>>>>>>=20
>>>>>> The principal strings are not equal, and that's why the client
>>>>>> believes the callback credential is bogus. Now I'm trying to
>>>>>> figure out whether it is the server's callback client or the
>>>>>> client's callback server that is misbehaving.
>>>>>>=20
>>>>>> To me, the server's callback principal (host@klimt) seems like it
>>>>>> is correct. The client would identify as host@manet when making
>>>>>> calls to the server, for example, so I'd expect the server to
>>>>>> behave similarly when performing callbacks.
>>>>>>=20
>>>>>> Can anyone shed more light on this?
>>>>>=20
>>>>> What are your full hostnames of each machine and does the reverse
>>>>> lookup from the ip to hostname on each machine give you what you
>>>>> expect?
>>>>>=20
>>>>> Sounds like all of them need to be resolved to =
<>.ib.1015grager.net
>>>>> but somewhere you are getting <>.1015grager.net instead.
>>>>=20
>>>> The forward and reverse mappings are consistent, and rdns is
>>>> disabled in my krb5.conf files. My server is multi-homed; it
>>>> has a 1GbE interface (klimt.1015granger.net); an FDR IB
>>>> interface (klimt.ib.1015granger.net); and a 25 GbE interface
>>>> (klimt.roce.1015granger.net).
>>>=20
>>> Ah, so you are keeping it very interesting...
>>>=20
>>>> My theory is that the server needs to use the same principal
>>>> for callback operations that the client used for lease
>>>> establishment. The last paragraph of S3.3.3 seems to state
>>>> that requirement, though it's not especially clear; and the
>>>> client has required it since commit f11b2a1cfbf5 (2014).
>>>>=20
>>>> So the server should authenticate as nfs@klimt.ib and not
>>>> host@klimt, in this case, when performing callback requests.
>>>=20
>>> Yes I agree that server should have authenticated as nfs@klmit.ib =
and
>>> that's what I see in my (simple) single home setup.
>>>=20
>>> In nfs-utils there is code that deals with the callback and comment
>>> about choices for the principal:
>>>        * Restricting gssd to use "nfs" service name is needed for =
when
>>>        * the NFS server is doing a callback to the NFS client.  In =
this
>>>        * case, the NFS server has to authenticate itself as "nfs" --
>>>        * even if there are other service keys such as "host" or =
"root"
>>>        * in the keytab.
>>> So the upcall for the callback should have specifically specified
>>> "nfs" to look for the nfs/<hostname>. Question is if you key tab has
>>> both:
>>> nfs/klmit and nfs/klmit.ib how does it choose which one to take. I'm
>>> not sure. But I guess in your case you are seeing that it choose
>>> "host/<>" which would really be a nfs-utils bug.
>>=20
>> I think the upcall is correctly requesting an nfs/ principal
>> (see below).
>>=20
>> Not only does it need to choose an nfs/ principal, but it also
>> has to pick the correct domain name. The domain name does not
>> seem to be passed up to gssd. fs/nfsd/nfs4state.c has this:

Sorry, this is fs/nfsd/nfs4callback.c


>> 749 static struct rpc_cred *callback_cred;
>> 750
>> 751 int set_callback_cred(void)
>> 752 {
>> 753         if (callback_cred)
>> 754                 return 0;
>> 755         callback_cred =3D rpc_lookup_machine_cred("nfs");
>> 756         if (!callback_cred)
>> 757                 return -ENOMEM;
>> 758         return 0;
>> 759 }
>> 760
>> 761 void cleanup_callback_cred(void)
>> 762 {
>> 763         if (callback_cred) {
>> 764                 put_rpccred(callback_cred);
>> 765                 callback_cred =3D NULL;
>> 766         }
>> 767 }
>> 768
>> 769 static struct rpc_cred *get_backchannel_cred(struct nfs4_client =
*clp, struct rpc_clnt *client, struct nfsd4_session *ses)
>> 770 {
>> 771         if (clp->cl_minorversion =3D=3D 0) {
>> 772                 return get_rpccred(callback_cred);
>> 773         } else {
>> 774                 struct rpc_auth *auth =3D client->cl_auth;
>> 775                 struct auth_cred acred =3D {};
>> 776
>> 777                 acred.uid =3D ses->se_cb_sec.uid;
>> 778                 acred.gid =3D ses->se_cb_sec.gid;
>> 779                 return auth->au_ops->lookup_cred(client->cl_auth, =
&acred, 0);
>> 780         }
>> 781 }
>>=20
>> rpc_lookup_machine_cred("nfs"); should request an "nfs/" service
>> principal, shouldn't it?

It doesn't seem to generate an upcall.


>> Though I think this approach is incorrect. The server should not
>> use the machine cred here, it should use a credential based on
>> the principal the client used to establish it's lease.
>>=20
>>=20
>>> What's in your server's key tab?
>>=20
>> [root@klimt ~]# klist -ke /etc/krb5.keytab
>> Keytab name: FILE:/etc/krb5.keytab
>> KVNO Principal
>> ---- =
--------------------------------------------------------------------------=

>>   4 host/klimt.1015granger.net@1015GRANGER.NET =
(aes256-cts-hmac-sha1-96)
>>   4 host/klimt.1015granger.net@1015GRANGER.NET =
(aes128-cts-hmac-sha1-96)
>>   4 host/klimt.1015granger.net@1015GRANGER.NET (des3-cbc-sha1)
>>   4 host/klimt.1015granger.net@1015GRANGER.NET (arcfour-hmac)
>>   3 nfs/klimt.1015granger.net@1015GRANGER.NET =
(aes256-cts-hmac-sha1-96)
>>   3 nfs/klimt.1015granger.net@1015GRANGER.NET =
(aes128-cts-hmac-sha1-96)
>>   3 nfs/klimt.1015granger.net@1015GRANGER.NET (des3-cbc-sha1)
>>   3 nfs/klimt.1015granger.net@1015GRANGER.NET (arcfour-hmac)
>>   3 nfs/klimt.ib.1015granger.net@1015GRANGER.NET =
(aes256-cts-hmac-sha1-96)
>>   3 nfs/klimt.ib.1015granger.net@1015GRANGER.NET =
(aes128-cts-hmac-sha1-96)
>>   3 nfs/klimt.ib.1015granger.net@1015GRANGER.NET (des3-cbc-sha1)
>>   3 nfs/klimt.ib.1015granger.net@1015GRANGER.NET (arcfour-hmac)
>>   3 nfs/klimt.roce.1015granger.net@1015GRANGER.NET =
(aes256-cts-hmac-sha1-96)
>>   3 nfs/klimt.roce.1015granger.net@1015GRANGER.NET =
(aes128-cts-hmac-sha1-96)
>>   3 nfs/klimt.roce.1015granger.net@1015GRANGER.NET (des3-cbc-sha1)
>>   3 nfs/klimt.roce.1015granger.net@1015GRANGER.NET (arcfour-hmac)
>> [root@klimt ~]#
>>=20
>> As a workaround, I bet moving the keys for nfs/klimt.ib to
>> the front of the keytab file would allow Kerberos to work
>> with the klimt.ib interface.
>>=20
>>=20
>>> An output from gssd -vvv would be interesting.
>>=20
>> May 10 14:43:24 klimt rpc.gssd[1191]: #012handle_gssd_upcall: =
'mech=3Dkrb5 uid=3D0 target=3Dhost@manet.1015granger.net service=3Dnfs =
enctypes=3D18,17,16,2
>> 3,3,1,2 ' (nfsd4_cb/clnt0)
>> May 10 14:43:24 klimt rpc.gssd[1191]: krb5_use_machine_creds: uid 0 =
tgtname host@manet.1015granger.net
>> May 10 14:43:24 klimt rpc.gssd[1191]: Full hostname for =
'manet.1015granger.net' is 'manet.1015granger.net'
>> May 10 14:43:24 klimt rpc.gssd[1191]: Full hostname for =
'klimt.1015granger.net' is 'klimt.1015granger.net'
>=20
> I think that's the problem. This should have been
> klimt.ib.1015granger.net. nfs-utils just calls gethostname() to get
> the local domain name. And this is what it'll match against the key
> tab entry. So I think even if you move the key tabs around it probably
> will still pick nfs@klmit.1015granger.net.
>=20
> Honestly, I'm also surprised that "target=3Dhost@manet.1015granger.net"
> and not "target=3Dhost@manet.ib.1015granger.net". What principal name
> did the client use to authenticate to the server?  I also somehow
> assumed that this should have been
> "target=3Dnfs@manet.ib.1015granger.net".

Likely for the same reason you state, nfs-utils on the client
will use gethostname(3) to do the keytab lookup. And I didn't
put any nfs/ principals in my client keytab:

[root@manet ~]# klist -ke /etc/krb5.keytab
Keytab name: FILE:/etc/krb5.keytab
KVNO Principal
---- =
--------------------------------------------------------------------------=

   2 host/manet.1015granger.net@1015GRANGER.NET =
(aes256-cts-hmac-sha1-96)=20
   2 host/manet.1015granger.net@1015GRANGER.NET =
(aes128-cts-hmac-sha1-96)=20
   2 host/manet.1015granger.net@1015GRANGER.NET (des3-cbc-sha1)=20
   2 host/manet.1015granger.net@1015GRANGER.NET (arcfour-hmac)=20
[root@manet ~]#


>> May 10 14:43:24 klimt rpc.gssd[1191]: Success getting keytab entry =
for 'nfs/klimt.1015granger.net@1015GRANGER.NET'
>> May 10 14:43:24 klimt rpc.gssd[1191]: gssd_get_single_krb5_cred: =
principal 'nfs/klimt.1015granger.net@1015GRANGER.NET' =
ccache:'FILE:/tmp/krb5ccmachine_1015GRANGER.NET'
>> May 10 14:43:24 klimt rpc.gssd[1191]: INFO: Credentials in CC =
'FILE:/tmp/krb5ccmachine_1015GRANGER.NET' are good until 1526064204
>> May 10 14:43:24 klimt rpc.gssd[1191]: creating tcp client for server =
manet.1015granger.net
>> May 10 14:43:24 klimt rpc.gssd[1191]: creating context with server =
host@manet.1015granger.net
>> May 10 14:43:24 klimt rpc.gssd[1191]: doing downcall: =
lifetime_rec=3D76170 acceptor=3Dhost@manet.1015granger.net
>> May 10 14:44:31 klimt rpc.gssd[1191]: #012handle_gssd_upcall: =
'mech=3Dkrb5 uid=3D0 target=3Dhost@manet.1015granger.net service=3Dnfs =
enctypes=3D18,17,16,23,3,1,2 ' (nfsd4_cb/clnt1)
>> May 10 14:44:31 klimt rpc.gssd[1191]: krb5_use_machine_creds: uid 0 =
tgtname host@manet.1015granger.net
>> May 10 14:44:31 klimt rpc.gssd[1191]: Full hostname for =
'manet.1015granger.net' is 'manet.1015granger.net'
>> May 10 14:44:31 klimt rpc.gssd[1191]: Full hostname for =
'klimt.1015granger.net' is 'klimt.1015granger.net'
>> May 10 14:44:31 klimt rpc.gssd[1191]: Success getting keytab entry =
for 'nfs/klimt.1015granger.net@1015GRANGER.NET'
>> May 10 14:44:31 klimt rpc.gssd[1191]: INFO: Credentials in CC =
'FILE:/tmp/krb5ccmachine_1015GRANGER.NET' are good until 1526064204
>> May 10 14:44:31 klimt rpc.gssd[1191]: INFO: Credentials in CC =
'FILE:/tmp/krb5ccmachine_1015GRANGER.NET' are good until 1526064204
>> May 10 14:44:31 klimt rpc.gssd[1191]: creating tcp client for server =
manet.1015granger.net
>> May 10 14:44:31 klimt rpc.gssd[1191]: creating context with server =
host@manet.1015granger.net
>> May 10 14:44:31 klimt rpc.gssd[1191]: doing downcall: =
lifetime_rec=3D76103 acceptor=3Dhost@manet.1015granger.net
>=20
> Going back to the original mail where you wrote:
>=20
> check_gss_callback_principal: acceptor=3Dnfs@klimt.ib.1015granger.net,
> principal=3Dhost@klimt.1015granger.net
>=20
> Where is this output on the client kernel or server kernel?
>=20
> According to the gssd output. In the callback authentication
> nfs@klimt.1015granger.net is authenticating to
> host@manet.1015granger.net. None of them match the
> "check_gss_callback_principal" output. So I'm confused...

This is instrumentation I added to the check_gss_callback_principal
function on the client. The above is gssd output on the server.

The client seems to be checking the acceptor (nfs@klimt.ib) of
the forward channel GSS context against the principal the server
actually uses (host@klimt) to establish the backchannel GSS
context.


>>>> This seems to mean that the server stack is going to need to
>>>> expose the SName in each GSS context so that it can dig that
>>>> out to create a proper callback credential for each callback
>>>> transport.
>>>>=20
>>>> I guess I've reported this issue before, but now I'm tucking
>>>> in and trying to address it correctly.

--
Chuck Lever



