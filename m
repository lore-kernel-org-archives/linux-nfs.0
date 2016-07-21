Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: Coddington Benjamin <bcodding@redhat.com>
CC: "hch@infradead.org" <hch@infradead.org>,
        List Linux
	<linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] Getattr doesn't require data sync semantics
Date: Thu, 21 Jul 2016 12:46:55 +0000
Message-ID: <E33497F6-079C-4903-9CC5-0ABDFA149694@primarydata.com>
References: <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <20160718034847.GA1195@infradead.org>
 <A9C18137-87A3-4652-ADD6-E8E1C4BAE27B@primarydata.com>
 <1468817945.5273.2.camel@primarydata.com>
 <20160719035843.GA24437@infradead.org>
 <F879054A-2116-40D5-90C9-473E71977E8A@redhat.com>
 <C44AB0DD-8FA3-42F2-B7DE-C694559A68EF@primarydata.com>
 <AB904138-E761-4F8F-AF97-0E8A4E067DB1@redhat.com>
 <20160721082216.GA15247@infradead.org>
 <A540F5A1-37B3-40EB-876D-EC33E891F0C9@redhat.com>
 <B4719B7F-3FC4-4FD7-929E-CC528CA867F4@redhat.com>
 <9E2543EF-0442-491E-AB22-3E1667DABBA4@redhat.com>
In-Reply-To: <9E2543EF-0442-491E-AB22-3E1667DABBA4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 21, 2016, at 05:52, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
>=20
> On 21 Jul 2016, at 5:10, Benjamin Coddington wrote:
>=20
>> On 21 Jul 2016, at 4:32, Benjamin Coddington wrote:
>>=20
>>> On 21 Jul 2016, at 4:22, hch@infradead.org wrote:
>>>=20
>>>> On Wed, Jul 20, 2016 at 11:03:06AM -0400, Benjamin Coddington wrote:
>>>>>>> This debug output is identical for every cycle of the loop. Have to
>>>>>>> stop for the
>>>>>>> day.. more tomorrow.
>>>>>>>=20
>>>>>>> Ben
>>>>>>>=20
>>>>>>=20
>>>>>> Duh??? It???s this patch: pNFS: Fix post-layoutget error handling in
>>>>>> pnfs_update_layout()
>>>>>> We have to pass through fatal errors??? I???ll fix it.
>>>>>=20
>>>>> That's indeed fixed it up, and generic/207 passes now.  Thanks!
>>>>=20
>>>> So I spoke too soon in my last mail, generic/207 still fails for me
>>>> with Trond's linux-next tree, although much later in the test now.
>>>>=20
>>>> Does it include the changes that are supposed to fix the issue?
>>>=20
>>> It should -- the v2 that fixed 207 for me is 56b38a1f7c781519eef09c1668=
a3c97ea911f86b, the first version was e35c2a0b3cd062a8941d21511719391b64437=
427, I think.  I'll test again too.
>>=20
>> Looks like we're back to the original problem - it fails with the inode =
size is 4k less than expected.
>>=20
>> The reason it worked for me was I had pnfs_ld debugging turned up which =
slowed things down enough to somehow catch the right size.
>>=20
>> Looks like the right size is returned in the CLOSE, but the inode's not =
getting updated.
>=20
> And the size is right in the last LAYOUTCOMMIT response, of course.  Is t=
his the problem?
>=20
> 6024 static int decode_layoutcommit(struct xdr_stream *xdr,
> ...
> 6040     sizechanged =3D be32_to_cpup(p);
> 6041
> 6042     if (sizechanged) {
> 6043         /* throw away new size */
> 6044         p =3D xdr_inline_decode(xdr, 8);
>=20
>=20
> Ben
>=20

That shouldn=92t really matter since we have a GETATTR immediately followin=
g the LAYOUTGET operation. Assuming that nfs4_proc_layoutcommit() actually =
gets called, it is supposed to update the inode correctly.

Cheers
  Trond
