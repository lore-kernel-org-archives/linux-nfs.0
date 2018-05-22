Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:41310 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751575AbeEVVCI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 17:02:08 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [RFC] protect against denial-of-service on a 4.0 mount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyHLEm3SQ5_ayDr6_TECpQndN_haKSyodf7Ls61RbLR2_g@mail.gmail.com>
Date: Tue, 22 May 2018 14:02:00 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E54CA1D0-00E7-4EEF-B77F-78B65AF2FC08@oracle.com>
References: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
 <594BD2F7-35FC-4E26-81D7-404194B7005A@oracle.com>
 <CAN-5tyHXhy7yS+6mNAyTzr9tX4vA9gma8AeRtvNG0-FNZaL_Yg@mail.gmail.com>
 <537AAFBD-62BA-4F0B-9B2E-D27500A1205B@oracle.com>
 <CAN-5tyHLEm3SQ5_ayDr6_TECpQndN_haKSyodf7Ls61RbLR2_g@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 22, 2018, at 1:38 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Tue, May 22, 2018 at 4:22 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On May 22, 2018, at 1:17 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>=20
>>> On Tue, May 22, 2018 at 4:08 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>=20
>>>>=20
>>>>> On May 22, 2018, at 1:03 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>=20
>>>>> I'm looking for comments on the approach to deal with the =
following
>>>>> denial-of-service issue.
>>>>>=20
>>>>> Currently, during the nfs4.0 mount, the code takes the content
>>>>> supplied by the user in the mount command for "clientaddr" and =
that
>>>>> becomes part of the content of the SETCLIENTID client id. There =
are no
>>>>> verifications that the supplied address belongs to the client
>>>>> initiating the mount.
>>>>>=20
>>>>> A denial of services comes from where there are 2 clients with IP =
A
>>>>> and IP B (bad one). Client IP A mounts and has "IP A" in the
>>>>> SETCLIENTID. Client IP B does a mount and specified "clientaddr=3DIP=
 A".
>>>>> This causes the server to invalidate the lease for the legitimate
>>>>> client IP A.
>>>>=20
>>>> Generally if this is a concern, Kerberos can be used during
>>>> the SETCLIENTID to mutually authenticate the client and
>>>> server. Shouldn't that prevent client B from tampering with
>>>> client A's lease?
>>>=20
>>> It turns out to be a concern by folks (customers) that are using the
>>> code. Kerberos does not help here. Client IP B can have a valid
>>> Kerberos identity and still supply "clientaddr=3D" not belonging to =
it
>>> for the SETCLIENTID and interfere with the other's lease.
>>=20
>> SETCLIENTID is associated with a client ID string and a Kerberos
>> principal. The server is supposed to deny a client with the same
>> string (and perhaps the same callback information) but a different
>> Kerberos identity from purging an existing lease belonging to a
>> different principal. NFS4ERR_CLID_INUSE.
>>=20
>> Are you saying the two clients have exactly the same host
>> principal? That seems... wrong.
>>=20
>=20
> Are you sure client ID is associated with a Kerberos principal?
>=20
> Looking ta the code that constructs the clientid content. I don't see
> that cl_nodename takes in principal identity.
>        scnprintf(str, len, "Linux NFSv%u.%u %s",
>                        clp->rpc_ops->version, clp->cl_minorversion,
>                        clp->cl_rpcclient->cl_nodename);

That's correct.

Normally the Linux client picks up the host principal in the
client's keytab and uses that as the credential for lease
management operations like SETCLIENTID, without any regard to
whether sec=3Dsys or sec=3Dkrb5-yada is used on the mount command.
The client ID string is not supposed to change between those
cases.

The server associates the client ID string with the Kerberos
principal the client used to perform the SETCLIENTID.

If a different Kerberos principal is used with a SETCLIENTID
that bears the same client ID string as a client whose lease
is still active, the server is supposed to reject that
SETCLIENTID with NFS4ERR_CLID_INUSE.


> I have also tried to do a mount with and without Kerberos and the
> clientid string is that same has NFSv4.0 client ip/server ip.

A quick way to disable the use of Kerberos for lease management
is to

  sudo mv /etc/krb5.keytab /etc/krb5.keytab.bak

and then restart rpc.gssd.

If the clients are using AUTH_UNIX credentials for SETCLIENTID,
client A and client B would have to have the same cl_nodename
to be able to futz with each others leases. Is that the case?

There used to be a way to get the client to include a uniquifier
in the client ID string. Has that logic been removed?

--
Chuck Lever



