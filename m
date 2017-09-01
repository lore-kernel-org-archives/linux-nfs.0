Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:6105 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752329AbdIAUe0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Sep 2017 16:34:26 -0400
Content-Type: text/plain; charset=utf-8
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v1 00/17] NFSD support for inter+async COPY
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170901200922.GA2743@parsley.fieldses.org>
Date: Fri, 1 Sep 2017 16:34:16 -0400
CC: Olga Kornievskaia <aglo@umich.edu>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <956F5336-01C8-402C-B59C-E94761A8BB90@netapp.com>
References: <20170302160142.30413-1-kolga@netapp.com>
 <20170901194130.GA27922@parsley.fieldses.org>
 <CAN-5tyGfQu15gPCKy0k=63BHC7tctPi-ebwR0tw9QgJzfLNOYw@mail.gmail.com>
 <20170901195345.GD27922@parsley.fieldses.org>
 <CDD9BC3A-0E15-45B2-8094-A8266EAD432C@netapp.com>
 <20170901200922.GA2743@parsley.fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 1, 2017, at 4:09 PM, J. Bruce Fields <bfields@redhat.com> =
wrote:
>=20
> On Fri, Sep 01, 2017 at 04:02:48PM -0400, Olga Kornievskaia wrote:
>>=20
>>> On Sep 1, 2017, at 3:53 PM, J. Bruce Fields <bfields@redhat.com> =
wrote:
>>>=20
>>> On Fri, Sep 01, 2017 at 03:48:33PM -0400, Olga Kornievskaia wrote:
>>>> On Fri, Sep 1, 2017 at 3:41 PM, J. Bruce Fields =
<bfields@redhat.com> wrote:
>>>>>       - what currently happens if you try to copy across krb5 =
mounts?
>>>>=20
>>>> No GSSv3 is included in these patches.  The destination server will
>>>> mount the source server using auth_sys.
>>>=20
>>> Assuming that doesn't work--how is the failure handled?
>>=20
>> If mount fails? Destination server returns an error in COPY (whatever
>> vfs_kern_mount can return). Client calls generic =
nfs4_handle_exception()=20
>> but it=E2=80=99s probably a kind of error it doesn=E2=80=99t handle =
so it=E2=80=99ll be translated to EIO.=20
>> What kind of error are you thinking about?
>=20
> I just want to make sure that copy_file_range() caller knows what to =
do
> when it encounters this situation.
>=20
> The typical application probably wants to fall back on a read-write =
loop
> in the case inter-server copy isn't supported between the given =
mounts?
>=20
> EIO doesn't sound like the most helpful error to me, but whatever =
error
> it is, it should be documented in the copy_file_range man page so that
> callers know how to check for this case.

On the client side, if we were to receive an error code that signified a =
connection=20
problem, then COPY implementation could map that to something that would
trigger the VFS to just fallback to do_splice.=20

However, I couldn=E2=80=99t find any errors in 15.1 from rfc5661 or 11.1 =
from 7862 that
could mean connection errors (that=E2=80=99s typically RPC errors =
right).=20=
