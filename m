Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:37496 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752161AbeEVUWd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 16:22:33 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [RFC] protect against denial-of-service on a 4.0 mount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyHXhy7yS+6mNAyTzr9tX4vA9gma8AeRtvNG0-FNZaL_Yg@mail.gmail.com>
Date: Tue, 22 May 2018 13:22:25 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <537AAFBD-62BA-4F0B-9B2E-D27500A1205B@oracle.com>
References: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
 <594BD2F7-35FC-4E26-81D7-404194B7005A@oracle.com>
 <CAN-5tyHXhy7yS+6mNAyTzr9tX4vA9gma8AeRtvNG0-FNZaL_Yg@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 22, 2018, at 1:17 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Tue, May 22, 2018 at 4:08 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On May 22, 2018, at 1:03 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>=20
>>> I'm looking for comments on the approach to deal with the following
>>> denial-of-service issue.
>>>=20
>>> Currently, during the nfs4.0 mount, the code takes the content
>>> supplied by the user in the mount command for "clientaddr" and that
>>> becomes part of the content of the SETCLIENTID client id. There are =
no
>>> verifications that the supplied address belongs to the client
>>> initiating the mount.
>>>=20
>>> A denial of services comes from where there are 2 clients with IP A
>>> and IP B (bad one). Client IP A mounts and has "IP A" in the
>>> SETCLIENTID. Client IP B does a mount and specified "clientaddr=3DIP =
A".
>>> This causes the server to invalidate the lease for the legitimate
>>> client IP A.
>>=20
>> Generally if this is a concern, Kerberos can be used during
>> the SETCLIENTID to mutually authenticate the client and
>> server. Shouldn't that prevent client B from tampering with
>> client A's lease?
>=20
> It turns out to be a concern by folks (customers) that are using the
> code. Kerberos does not help here. Client IP B can have a valid
> Kerberos identity and still supply "clientaddr=3D" not belonging to it
> for the SETCLIENTID and interfere with the other's lease.

SETCLIENTID is associated with a client ID string and a Kerberos
principal. The server is supposed to deny a client with the same
string (and perhaps the same callback information) but a different
Kerberos identity from purging an existing lease belonging to a
different principal. NFS4ERR_CLID_INUSE.

Are you saying the two clients have exactly the same host
principal? That seems... wrong.


>>> My suggested approach to fixing it, is to have nfs-utils do a sanity
>>> checking that will check if the clientaddr that's suppose matches =
the
>>> IP of the machine. Then currently, if it doesn't then it will ignore
>>> the supplied value and use the IP of the machine. Whether this is
>>> desirable vs say failing the mount and forcing the user to specify =
the
>>> correct value is up for debate. Also, I'm not sure if the check for
>>> the value of clientaddr should be done in the kernel itself instead =
of
>>> the nfs-utils.
>>>=20
>>> Below is the rough fix to the nfs-utils. Please comment.
>>=20
>> One thing we want to be able to continue to do is specify
>> "clientaddr=3D0.0.0.0" to disable NFSv4.0 callback (and thus
>> delegation).
>=20
> Ok so some extra logic to check for the special value?

There is some value in stronger input validation here,
outside of the particular issue you described above. I
think such validation should allow INADDR_ANY (and the
IPv6 equivalent).


>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 1217823..982927e 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -242,11 +242,21 @@ static int nfs_append_clientaddr_option(const
>>> struct sockaddr *sap,
>>> struct sockaddr *my_addr =3D &address.sa;
>>> socklen_t my_len =3D sizeof(address);
>>>=20
>>> - if (po_contains(options, "clientaddr") =3D=3D PO_FOUND)
>>> - return 1;
>>> -
>>> nfs_callback_address(sap, salen, my_addr, &my_len);
>>>=20
>>> + if (po_contains(options, "clientaddr") =3D=3D PO_FOUND) {
>>> + char *addr =3D po_get(options, "clientaddr");
>>> +         char address[NI_MAXHOST];
>>> +
>>> +         if (!nfs_present_sockaddr(my_addr, my_len, address,
>>> + sizeof(address)))
>>> +                 goto out;
>>> +
>>> + if (strcmp(addr, address))
>>> + goto out;
>>> + return 1;
>>> + }
>>> +out:
>>> return nfs_append_generic_address_option(my_addr, my_len,
>>> "clientaddr", options);
>>> }
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>> --
>> Chuck Lever

--
Chuck Lever



