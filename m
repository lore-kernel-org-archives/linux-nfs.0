Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46368 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727069AbeIFBov (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Sep 2018 21:44:51 -0400
From: NeilBrown <neilb@suse.com>
To: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 06 Sep 2018 07:12:42 +1000
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 session reset needs to update ->rsize and ->wsize - how???
In-Reply-To: <CAN-5tyG0DXosk0RUCM6E+pj-EmMWW5tuKfPg4HJChp9snvcQAQ@mail.gmail.com>
References: <87r2i8vq10.fsf@notabene.neil.brown.name> <f7f84aced6ae709b1c66e1475e8d79927fa29132.camel@hammerspace.com> <87o9dcvmk6.fsf@notabene.neil.brown.name> <CAN-5tyG0DXosk0RUCM6E+pj-EmMWW5tuKfPg4HJChp9snvcQAQ@mail.gmail.com>
Message-ID: <87lg8fveb9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Sep 05 2018, Olga Kornievskaia wrote:

> On Tue, Sep 4, 2018 at 8:04 PM NeilBrown <neilb@suse.com> wrote:
>>
>> On Tue, Sep 04 2018, Trond Myklebust wrote:
>>
>> > On Wed, 2018-09-05 at 08:47 +1000, NeilBrown wrote:
>> >> With NFSv4.1, the server specifies max_rqst_sz and max_resp_sz in the
>> >> reply to CREATE session.
>> >>
>> >> If the client finds it needs to call nfs4_reset_session(), it might
>> >> get
>> >> smaller sizes back, so any pending read/writes would need to be
>> >> resized.
>> >>
>> >> However, I cannot see how the retry handling for reads/writes has any
>> >> chance to change the size.  It looks like a request is broken up to
>> >> match the original ->rsize and ->wsize, then those individual IO
>> >> requests can be retried, but the higher level request is never
>> >> re-evaluated in light of a new size.
>> >>
>> >> Am I missing something, or is this not supported at present?
>> >> If it isn't supported, any suggestions on how best to handle a
>> >> reduction of the rsize/wsize ??
>> >>
>> >
>> > Why would a sane server want to do this?
>>
>> Why would a sane protocol support it? :-)
>>
>> I have a network trace of SLE11-SP4 (3.0 based) talking to "a NetApp
>> appliance".
>> It sends a 64K write and gets NFS4ERR_REQ_TOO_BIG.
>> It then closes the file (getting NFS4ERR_SEQ_MISORDERED even though it
>> used a seq number 1 more than the WRITE request), and then
>> DESTROY_SESSION and CREATE_SESSION.
>> The CREATE_SESSION gets "max req size" of 33812 and "max resp size" of
>> 33672.
>> It then opens the file again and retries the 64K write....
>>
>> I have a separate trace showing the initial mount where the sizes are 71680
>> and 81920.
>>
>> I don't have a trace where it stops working, but reportedly writes work
>> smoothly for some hours after a mount, but then suddenly stop working.
>>
>> The CREATE_SESSION *call* requests I see have the small (32K) sizes, but
>> presumably they are the result of a previous CREATE_SESSION reply giving
>> a small value.
>>
>> I just had a thought.
>> If one session is shared by two "struct nfs_server" with different
>> ->rsize or ->wsize, then the session might get set up with the smaller
>> size, and the mount using the larger size will get confused.
>> In 3.0 (and even 3.10) nfs4_init_session() limits the requested session
>> parameters to ->rsize and ->wsize.
>> That changed in 18aad3d552c7.
>>
>> Maybe I just need to remove that code from nfs4_init_session().
>> I'll give it a try.
>>
>
> Neil, does the code have this commit?
>
> commit 033853325fe3bdc70819a8b97915bd3bca41d3af
> Author: Olga Kornievskaia <kolga@netapp.com>
> Date:   Wed Mar 8 14:39:15 2017 -0500
>
>     NFSv4.1 respect server's max size in CREATE_SESSION
>
>     Currently client doesn't respect max sizes server returns in CREATE_SESSION.
>     nfs4_session_set_rwsize() gets called and server->rsize, server->wsize are 0
>     so they never get set to the sizes returned by the server.
>
>     Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>
>> Thanks,
>> NeilBrown

Thanks for the suggestion.
The kernel doesn't have that patch, but I don't think it is relevant.
The ->rsize does have a suitable value - it isn't zero.
The problem is that the session limit appears to change, and the client
doesn't adjust to the change.

My current theory is that the client actually requested the change,
though on behalf of a different filesystem using the same session.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAluQRsoACgkQOeye3VZi
gblDhw/+L79Rx046mDYTD7DzgfbMCmwHSkG44dZ2eN3E5pFTzkg+JH/A7vue54nk
U2orX/A10hzvMUreM2rWRMcqudWidgikQFwWe/vb+ua8yic3vgqRlKk2uN6Anuru
2tNXgsA+xJmOD+bV2wwNhZ32ZLpDZf1ibbvhtxZ5kYI6fsKRKun1QoiSmVe+sSRb
v/U6wAIQKPtcNc+8Ar6R15L0nGCvokmuMC6QriWUqulmGCETGo1R9Jgfse3XeY8/
+TMb1gKL4CHuGLE5LxyMsLnrptdGB70QReUDvcfesBdkNsNXPZUKhM48rYAdxM4e
TeFSAewoRMD8T3Yu4QipxGQjFqyg92EpCagGqBwmp5Jpb8I3TnPTGuxdqDKK/USO
NDcKwXXac8WbCV4N3m0bvTSHtQ1LCVI5fPR/T5krC+fuc893xmVo5r1d5Js/wc8C
S5kdu8+OWpgG3sw0m80e8w9PhiZ0egK1PzabNQT27KzUf4MPjuYGW7y2MnaB8m/l
ayke2WI28+SStbzC2uEGwY3X5f9V5qOe9bj4Ctq+ARDBzKspDXxVf+3mr3U7p3z5
bAn7VcwSP0L71YqU1PulHZZRricmUp9N4IBsnRqc7sgMF8Qf1AlbTHk8i9idlpOt
kcYa2NOS9tODXEU3fiPwkPQ7pj3c/v7bgqoN6n0rs/UeIPH7poo=
=c0Mf
-----END PGP SIGNATURE-----
--=-=-=--
