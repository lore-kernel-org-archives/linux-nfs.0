Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] svcauth_gss: Revert 64c59a3726f2 ("Remove unnecessary allocation")
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <9417A81A-BEBF-4B46-AF44-98B59D23D183@redhat.com>
Date: Wed, 7 Sep 2016 10:35:12 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CA2333CC-2494-47AB-8FE7-E63CA11C606A@oracle.com>
References: <20160901144839.6035.63068.stgit@klimt.1015granger.net> <20160906204238.GA30260@fieldses.org> <F9C6309A-2444-4B40-82D0-4BE90F19490A@oracle.com> <20160906210149.GB30260@fieldses.org> <B18D986B-5CC2-4D73-AD9C-525DBB4B93AD@oracle.com> <9417A81A-BEBF-4B46-AF44-98B59D23D183@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 6, 2016, at 7:49 PM, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
>=20
> On 6 Sep 2016, at 17:25, Chuck Lever wrote:
>=20
>>> On Sep 6, 2016, at 5:01 PM, J. Bruce Fields <bfields@fieldses.org> wrote=
:
>>>=20
>>>> On Tue, Sep 06, 2016 at 04:49:33PM -0400, Chuck Lever wrote:
>>>>=20
>>>>> On Sep 6, 2016, at 4:42 PM, J. Bruce Fields <bfields@fieldses.org> wro=
te:
>>>>> Apologies, I wasn't thinking when I wrote that patch.  The problem is
>>>>> probably that rsc_lookup steals the passed-in memory to avoid doing an=

>>>>> allocation of its own, so we can't just pass in a pointer to memory th=
at
>>>>> someone else is using....
>>>>>=20
>>>>> If we really want to avoid allocation there then maybe we should
>>>>> preallocate somwhere, or reference count these handles.
>>>>>=20
>>>>> For now reverting sounds like the right thing to do.
>>>>=20
>>>> NP, thanks for confirming!
>>>>=20
>>>>=20
>>>>> Ben, did you ever confirm whether this helped with the problem you wer=
e
>>>>> seeing?  (If I remember correctly, unnpredictable delays here could
>>>>> cause the request to be dropped if later requests push the rpcsec_gss
>>>>> sequence window too far.)  If so then we could look into reference
>>>>> counting.
>=20
> I somehow missed this; I haven't tested it.
>=20
>>>> Well that's interesting.
>>>>=20
>>>> When a request is dropped, would the server disconnect? Because if it
>>>> doesn't, the client will wait forever.
>>>=20
>>> Checking... gss_verify_header returns SVC_DROP, which is just a silent
>>> close (SVC_CLOSE would close the connection).
>>>=20
>>> I'm not sure what's correct there.
>>=20
>> Right, we may not get any guidance from the RPCSEC GSS specifications.
>>=20
>> However, the Linux NFS client retransmit code was changed in 2013 so that=

>> NFSv4 never retransmits until the server drops the connection, starting
>> around commit 8a19a0b6cb2e2216afd68ef2047f30260cc8a220.
>=20
> That is the behavior I was seeing.

I have a reproducer that is somewhat reliable. I will try using
SVC_CLOSE.=
