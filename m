Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:52474 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbeEVWgT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 18:36:19 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [RFC] protect against denial-of-service on a 4.0 mount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyGu++ULeUZKtZH=ZjUwqLNrcaZ4dSjH=iHXe0fCeudajA@mail.gmail.com>
Date: Tue, 22 May 2018 15:36:12 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <58E2765B-6238-479D-968A-0FE2F5F01928@oracle.com>
References: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
 <594BD2F7-35FC-4E26-81D7-404194B7005A@oracle.com>
 <CAN-5tyHXhy7yS+6mNAyTzr9tX4vA9gma8AeRtvNG0-FNZaL_Yg@mail.gmail.com>
 <537AAFBD-62BA-4F0B-9B2E-D27500A1205B@oracle.com>
 <CAN-5tyHLEm3SQ5_ayDr6_TECpQndN_haKSyodf7Ls61RbLR2_g@mail.gmail.com>
 <E54CA1D0-00E7-4EEF-B77F-78B65AF2FC08@oracle.com>
 <CAN-5tyH7gCyZ=-11TaYC3-WhYcB5n+W3Ua=TdDq=PZk24n+DbQ@mail.gmail.com>
 <EFDDE2C2-8E09-4F7A-B95A-785EA48E4804@oracle.com>
 <CAN-5tyGu++ULeUZKtZH=ZjUwqLNrcaZ4dSjH=iHXe0fCeudajA@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 22, 2018, at 3:11 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Tue, May 22, 2018 at 5:44 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On May 22, 2018, at 2:21 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>=20
>>> On Tue, May 22, 2018 at 5:02 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>=20
>>>>=20
>>>>> On May 22, 2018, at 1:38 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>=20
>>>>> On Tue, May 22, 2018 at 4:22 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>=20
>>>>>>=20
>>>>>>> On May 22, 2018, at 1:17 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>>>=20
>>>>>>> On Tue, May 22, 2018 at 4:08 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>> On May 22, 2018, at 1:03 PM, Olga Kornievskaia =
<aglo@umich.edu> wrote:
>>>>>>>>>=20
>>>>>>>>> I'm looking for comments on the approach to deal with the =
following
>>>>>>>>> denial-of-service issue.
>>>>>>>>>=20
>>>>>>>>> Currently, during the nfs4.0 mount, the code takes the content
>>>>>>>>> supplied by the user in the mount command for "clientaddr" and =
that
>>>>>>>>> becomes part of the content of the SETCLIENTID client id. =
There are no
>>>>>>>>> verifications that the supplied address belongs to the client
>>>>>>>>> initiating the mount.
>>>>>>>>>=20
>>>>>>>>> A denial of services comes from where there are 2 clients with =
IP A
>>>>>>>>> and IP B (bad one). Client IP A mounts and has "IP A" in the
>>>>>>>>> SETCLIENTID. Client IP B does a mount and specified =
"clientaddr=3DIP A".
>>>>>>>>> This causes the server to invalidate the lease for the =
legitimate
>>>>>>>>> client IP A.
>>>>>>>>=20
>>>>>>>> Generally if this is a concern, Kerberos can be used during
>>>>>>>> the SETCLIENTID to mutually authenticate the client and
>>>>>>>> server. Shouldn't that prevent client B from tampering with
>>>>>>>> client A's lease?
>>>>>>>=20
>>>>>>> It turns out to be a concern by folks (customers) that are using =
the
>>>>>>> code. Kerberos does not help here. Client IP B can have a valid
>>>>>>> Kerberos identity and still supply "clientaddr=3D" not belonging =
to it
>>>>>>> for the SETCLIENTID and interfere with the other's lease.
>>>>>>=20
>>>>>> SETCLIENTID is associated with a client ID string and a Kerberos
>>>>>> principal. The server is supposed to deny a client with the same
>>>>>> string (and perhaps the same callback information) but a =
different
>>>>>> Kerberos identity from purging an existing lease belonging to a
>>>>>> different principal. NFS4ERR_CLID_INUSE.
>>>>>>=20
>>>>>> Are you saying the two clients have exactly the same host
>>>>>> principal? That seems... wrong.
>>>>>>=20
>>>>>=20
>>>>> Are you sure client ID is associated with a Kerberos principal?
>>>>>=20
>>>>> Looking ta the code that constructs the clientid content. I don't =
see
>>>>> that cl_nodename takes in principal identity.
>>>>>      scnprintf(str, len, "Linux NFSv%u.%u %s",
>>>>>                      clp->rpc_ops->version, clp->cl_minorversion,
>>>>>                      clp->cl_rpcclient->cl_nodename);
>>>>=20
>>>> That's correct.
>>>>=20
>>>> Normally the Linux client picks up the host principal in the
>>>> client's keytab and uses that as the credential for lease
>>>> management operations like SETCLIENTID, without any regard to
>>>> whether sec=3Dsys or sec=3Dkrb5-yada is used on the mount command.
>>>> The client ID string is not supposed to change between those
>>>> cases.
>>>>=20
>>>> The server associates the client ID string with the Kerberos
>>>> principal the client used to perform the SETCLIENTID.
>>>=20
>>> I haven't checked the spec but is this required?
>>=20
>> Yes, it is required. That's what the NFS4ERR_CLID_INUSE status
>> code is for.
>>=20
>> RFC 7530 p. 291:
>>=20
>>      For any confirmed
>>      record with the same id string x, if the recorded principal does
>>      not match that of the SETCLIENTID call, then the server returns =
an
>>      NFS4ERR_CLID_INUSE error.
>>=20
>>=20
>>>> If a different Kerberos principal is used with a SETCLIENTID
>>>> that bears the same client ID string as a client whose lease
>>>> is still active, the server is supposed to reject that
>>>> SETCLIENTID with NFS4ERR_CLID_INUSE.
>>>=20
>>> I have tried (against the linux server), do a mount with krb5 and =
one
>>> without that used the clientaddr of the client with krb5 mount and I
>>> could get into the same lease revocation behavior. Which makes me
>>> question if indeed the servers do associate Kerberos principal in =
the
>>> SETCLIENTID handling.
>>=20
>> That sounds like a bad server bug to me.
>>=20
>> Input validation on a client can't possibly be a reliable fix
>> for this issue.
>=20
> But for auth_sys I believe it is helpful.

With AUTH_UNIX, the best you can do is try to ensure
that all your clients have unique cl_nodenames.

The question of whether the provided callback address is
valid is a different matter. "Is this user-provided
address one of my local interfaces or _ANY?" and then
either warn or fail the mount if not.


>> Preventing lease tampering is exactly why the
>> Linux client uses krb5i with the host principal for lease
>> management whenever it can.
>>=20
>>=20
>>>>> I have also tried to do a mount with and without Kerberos and the
>>>>> clientid string is that same has NFSv4.0 client ip/server ip.
>>>>=20
>>>> A quick way to disable the use of Kerberos for lease management
>>>> is to
>>>>=20
>>>> sudo mv /etc/krb5.keytab /etc/krb5.keytab.bak
>>>>=20
>>>> and then restart rpc.gssd.
>>>>=20
>>>> If the clients are using AUTH_UNIX credentials for SETCLIENTID,
>>>> client A and client B would have to have the same cl_nodename
>>>> to be able to futz with each others leases. Is that the case?
>>>=20
>>> That is correct. Auth_unix mount can do it. But so it turns out to =
be
>>> with Kerberos/auth_unix mix. I haven't tried Kerberos/Kerberos but =
it
>>> makes me thing that it will also be a problem (since mix is a
>>> problem).
>>=20
>> If an AUTH_UNIX client can tamper with a lease established
>> by an AUTH_GSS client, that's a pretty serious server bug.
>>=20
>> Which server implementation is this?
>=20
> This is linux 4.16-rc1.

Would it be easy for you confirm if two AUTH_GSS clients are
appropriately protected from each other? It would be good to
file a bug on bugzilla.linux-nfs.org to document the full
extent of the badness.


>>>> There used to be a way to get the client to include a uniquifier
>>>> in the client ID string. Has that logic been removed?
>>>=20
>>> I'm unaware of such logic. I wonder what that uniquer string used to
>>> be , a MAC address? The spec talks about how difficult it is to come
>>> up with a reboot persistent unique identifier.
>>=20
>> Search for nfs4_client_id_uniquifier .
>>=20
>> It's meant to be a UUID, but it can be any random string.
>> This can be set as a kernel boot parameter so it can be
>> stored on a network boot server.
>=20
> I see, ok thanks.
>>=20
>>=20
>> --
>> Chuck Lever

--
Chuck Lever



