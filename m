Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:56475 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752292AbdIAUC4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Sep 2017 16:02:56 -0400
Content-Type: text/plain; charset=utf-8
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v1 00/17] NFSD support for inter+async COPY
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170901195345.GD27922@parsley.fieldses.org>
Date: Fri, 1 Sep 2017 16:02:48 -0400
CC: Olga Kornievskaia <aglo@umich.edu>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <CDD9BC3A-0E15-45B2-8094-A8266EAD432C@netapp.com>
References: <20170302160142.30413-1-kolga@netapp.com>
 <20170901194130.GA27922@parsley.fieldses.org>
 <CAN-5tyGfQu15gPCKy0k=63BHC7tctPi-ebwR0tw9QgJzfLNOYw@mail.gmail.com>
 <20170901195345.GD27922@parsley.fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 1, 2017, at 3:53 PM, J. Bruce Fields <bfields@redhat.com> =
wrote:
>=20
> On Fri, Sep 01, 2017 at 03:48:33PM -0400, Olga Kornievskaia wrote:
>> On Fri, Sep 1, 2017 at 3:41 PM, J. Bruce Fields <bfields@redhat.com> =
wrote:
>>>        - what currently happens if you try to copy across krb5 =
mounts?
>>=20
>> No GSSv3 is included in these patches.  The destination server will
>> mount the source server using auth_sys.
>=20
> Assuming that doesn't work--how is the failure handled?

If mount fails? Destination server returns an error in COPY (whatever
 vfs_kern_mount can return). Client calls generic =
nfs4_handle_exception()=20
but it=E2=80=99s probably a kind of error it doesn=E2=80=99t handle so =
it=E2=80=99ll be translated to EIO.=20
What kind of error are you thinking about?

