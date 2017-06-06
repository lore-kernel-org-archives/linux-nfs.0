Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: GSS sequence number window
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170606202307.GI13376@fieldses.org>
Date: Tue, 6 Jun 2017 16:54:51 -0400
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2ED4D9A9-08B4-499C-BB76-EFCC5108D2FA@oracle.com>
References: <63736845-2BD3-4EE1-AC12-0BD21A9ABEF2@oracle.com> <20170530193419.GA9371@fieldses.org> <EC0579A3-BC81-4398-A11D-8D8EEFC473BF@redhat.com> <20170531192231.GA23526@fieldses.org> <C7BDFB27-72B4-4156-8272-BAE8AE89039B@oracle.com> <28665890-C74A-4319-B42E-475393821EC7@oracle.com> <20170606194158.GG13376@fieldses.org> <4D542D55-DCBA-4838-9DB2-B76B4068783E@oracle.com> <20170606201504.GH13376@fieldses.org> <F7960CBD-9E6C-478D-B390-F435DFD37DFB@oracle.com> <20170606202307.GI13376@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 6, 2017, at 4:23 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Tue, Jun 06, 2017 at 04:16:53PM -0400, Chuck Lever wrote:
>>=20
>>> On Jun 6, 2017, at 4:15 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>>>=20
>>> On Tue, Jun 06, 2017 at 03:45:59PM -0400, Chuck Lever wrote:
>>>>=20
>>>>> On Jun 6, 2017, at 3:41 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>>>>>=20
>>>>> On Tue, Jun 06, 2017 at 03:35:23PM -0400, Chuck Lever wrote:
>>>>>> I filed https://bugzilla.linux-nfs.org/show_bug.cgi?id=3D306
>>>>>>=20
>>>>>> To check memory allocation latency, I could always construct
>>>>>> a framework around kmalloc and alloc_page.
>>>>>>=20
>>>>>>=20
>>>>>> I've also found some bad behavior around proto=3Drdma,sec=3Dkrb5i.
>>>>>> When I run a heavy I/O workload (fio, for example), every so
>>>>>> often a read operation fails with EIO. I dug into it a little
>>>>>> and MIC verification fails for these replies on the client.
>>>>>=20
>>>>> Do we still have the problem that the read data can change between =
the
>>>>> time we calculate the MIC and the time we transmit the data to the
>>>>> client?
>>>>=20
>>>> I don't see a problem with krb5p, which, if IIUC, would also
>>>> fall victim to this situation, unless there is much stricter
>>>> request serialization going on with krb5p.
>>>=20
>>> We turn off zero-copy by clearing RQ_SPLICE_OK in the krb5p case.
>>=20
>> Seems like this is the right answer for krb5i too. Shall I try that?
>=20
> Sure!  Just grep around for RQ_SPLICE_OK, I think it should be easy to
> figure out.

I added

        clear_bit(RQ_SPLICE_OK, &rqstp->rq_flags);

at the top of unwrap_integ_data() in net/sunrpc/auth_gss/svcauth_gss.c.

I haven't seen a failure yet, which is a good sign.


> --b.
>>=20
>>=20
>>>> Even so, how would I detect if this issue was present?
>>>=20
>>> Good question.  If you knew the data and mic in the bad case, and =
had
>>> some way to guess what the previous data might have been based on =
what
>>> you knew about the test, then you could try mic's of likely older
>>> versions of the data and see if you get a match....  That sounds =
hard.
>>>=20
>>> --b.
>>=20
>> --
>> Chuck Lever

--
Chuck Lever
