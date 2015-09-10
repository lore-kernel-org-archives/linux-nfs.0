Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38483 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045AbbIJPtc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2015 11:49:32 -0400
Subject: Re: [PATCH v1 0/8] VFS: In-kernel copy system call
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <55EEFCEE.5090000@draigBrady.com> <55EF279B.3020101@Netapp.com>
 <CALCETrXxRB-LXVb+=nkwfj0zEjWuXXTctkSAc9Oec0fgyOQ5Yg@mail.gmail.com>
 <55EF3EFD.3080302@draigBrady.com> <20150908212907.GD30681@birch.djwong.org>
 <CALCETrWAotvN+MBsxq4QLQBr_WAyydqMnipcaTM88rM8sSx43w@mail.gmail.com>
 <20150908223959.GE30681@birch.djwong.org> <55F07FD8.4020507@Netapp.com>
 <20150909211636.GB10399@birch.djwong.org> <55F19D7F.5090907@Netapp.com>
Cc: Andy Lutomirski <luto@amacapital.net>,
        =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigbrady.com>,
        linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com,
        Christoph Hellwig <hch@infradead.org>, Coreutils <coreutils@gnu.org>
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <55F1A680.8010905@gmail.com>
Date: Thu, 10 Sep 2015 11:49:20 -0400
MIME-Version: 1.0
In-Reply-To: <55F19D7F.5090907@Netapp.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms040407030204040002010202"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms040407030204040002010202
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-09-10 11:10, Anna Schumaker wrote:
> On 09/09/2015 05:16 PM, Darrick J. Wong wrote:
>> On Wed, Sep 09, 2015 at 02:52:08PM -0400, Anna Schumaker wrote:
>>> On 09/08/2015 06:39 PM, Darrick J. Wong wrote:
>>>> On Tue, Sep 08, 2015 at 02:45:39PM -0700, Andy Lutomirski wrote:
>>>>> On Tue, Sep 8, 2015 at 2:29 PM, Darrick J. Wong <darrick.wong@oracl=
e.com> wrote:
>>>>>> On Tue, Sep 08, 2015 at 09:03:09PM +0100, P=C3=A1draig Brady wrote=
:
>>>>>>> On 08/09/15 20:10, Andy Lutomirski wrote:
>>>>>>>> On Tue, Sep 8, 2015 at 11:23 AM, Anna Schumaker
>>>>>>>> <Anna.Schumaker@netapp.com> wrote:
>>>>>>>>> On 09/08/2015 11:21 AM, P=C3=A1draig Brady wrote:
>>>>>>>>>> I see copy_file_range() is a reflink() on BTRFS?
>>>>>>>>>> That's a bit surprising, as it avoids the copy completely.
>>>>>>>>>> cp(1) for example considered doing a BTRFS clone by default,
>>>>>>>>>> but didn't due to expectations that users actually wanted
>>>>>>>>>> the data duplicated on disk for resilience reasons,
>>>>>>>>>> and for performance reasons so that write latencies were
>>>>>>>>>> restricted to the copy operation, rather than being
>>>>>>>>>> introduced at usage time as the dest file is CoW'd.
>>>>>>>>>>
>>>>>>>>>> If reflink() is a possibility for copy_file_range()
>>>>>>>>>> then could it be done optionally with a flag?
>>>>>>>>>
>>>>>>>>> The idea is that filesystems get to choose how to handle copies=
 in the
>>>>>>>>> default case.  BTRFS could do a reflink, but NFS could do a ser=
ver side
>>>>>>
>>>>>> Eww, different default behaviors depending on the filesystem. :)
>>>>>>
>>>>>>>>> copy instead.  I can change the default behavior to only do a d=
ata copy
>>>>>>>>> (unless the reflink flag is specified) instead, if that is desi=
rable.
>>>>>>>>>
>>>>>>>>> What does everybody think?
>>>>>>>>
>>>>>>>> I think the best you could do is to have a hint asking politely =
for
>>>>>>>> the data to be deep-copied.  After all, some filesystems reserve=
 the
>>>>>>>> right to transparently deduplicate.
>>>>>>>>
>>>>>>>> Also, on a true COW filesystem (e.g. btrfs sometimes), there may=
 be no
>>>>>>>> advantage to deep copying unless you actually want two copies fo=
r
>>>>>>>> locality reasons.
>>>>>>>
>>>>>>> Agreed. The relink and server side copy are separate things.
>>>>>>> There's no advantage to not doing a server side copy,
>>>>>>> but as mentioned there may be advantages to doing deep copies on =
BTRFS
>>>>>>> (another reason not previous mentioned in this thread, would be
>>>>>>> to avoid ENOSPC errors at some time in the future).
>>>>>>>
>>>>>>> So having control over the deep copy seems useful.
>>>>>>> It's debatable whether ALLOW_REFLINK should be on/off by default
>>>>>>> for copy_file_range().  I'd be inclined to have such a setting of=
f by default,
>>>>>>> but cp(1) at least will work with whatever is chosen.
>>>>>>
>>>>>> So far it looks like people are interested in at least these "make=
 data appear
>>>>>> in this other place" filesystem operations:
>>>>>>
>>>>>> 1. reflink
>>>>>> 2. reflink, but only if the contents are the same (dedupe)
>>>>>
>>>>> What I meant by this was: if you ask for "regular copy", you may en=
d
>>>>> up with a reflink anyway.  Anyway, how can you reflink a range and
>>>>> have the contents *not* be the same?
>>>>
>>>> reflink forcibly remaps fd_dest's range to fd_src's range.  If they =
didn't
>>>> match before, they will afterwards.
>>>>
>>>> dedupe remaps fd_dest's range to fd_src's range only if they match, =
of course.
>>>>
>>>> Perhaps I should have said "...if the contents are the same before t=
he call"?
>>>>
>>>>>
>>>>>> 3. regular copy
>>>>>> 4. regular copy, but make the hardware do it for us
>>>>>> 5. regular copy, but require a second copy on the media (no-dedupe=
)
>>>>>
>>>>> If this comes from me, I have no desire to ever use this as a flag.=

>>>>
>>>> I meant (5) as a "disable auto-dedupe for this operation" flag, not =
as
>>>> a "reallocate all the shared blocks now" op...
>>>>
>>>>> If someone wants to use chattr or some new operation to say "make t=
his
>>>>> range of this file belong just to me for purpose of optimizing futu=
re
>>>>> writes", then sure, go for it, with the understanding that there ar=
e
>>>>> plenty of filesystems for which that doesn't even make sense.
>>>>
>>>> "Unshare these blocks" sounds more like something fallocate could do=
=2E
>>>>
>>>> So far in my XFS reflink playground, it seems that using the defrag =
tool to
>>>> un-cow a file makes most sense.  AFAICT the XFS and ext4 defraggers =
copy a
>>>> fragmented file's data to a second file and use a 'swap extents' ope=
ration,
>>>> after which the donor file is unlinked.
>>>>
>>>> Hey, if this syscall turns into a more generic "do something involvi=
ng two
>>>> (fd:off:len) (fd:off:len) tuples" call, I guess we could throw in "s=
wap
>>>> extents" as a 7th operation, to refactor the ioctls.  <smirk>
>>>>
>>>>>
>>>>>> 6. regular copy, but don't CoW (eatmyothercopies) (joke)
>>>>>>
>>>>>> (Please add whatever ops I missed.)
>>>>>>
>>>>>> I think I can see a case for letting (4) fall back to (3) since (4=
) is an
>>>>>> optimization of (3).
>>>>>>
>>>>>> However, I particularly don't like the idea of (1) falling back to=
 (3-5).
>>>>>> Either the kernel can satisfy a request or it can't, but let's not=
 just
>>>>>> assume that we should transmogrify one type of request into anothe=
r.  Userspace
>>>>>> should decide if a reflink failure should turn into one of the cop=
y variants,
>>>>>> depending on whether the user wants to spread allocation costs ove=
r rewrites or
>>>>>> pay it all up front.  Also, if we allow reflink to fall back to co=
py, how do
>>>>>> programs find out what actually took place?  Or do we simply not a=
llow them to
>>>>>> find out?
>>>>>>
>>>>>> Also, programs that expect reflink either to finish or fail quickl=
y might be
>>>>>> surprised if it's possible for reflink to take a longer time than =
usual and
>>>>>> with the side effect that a deep(er) copy was made.
>>>>>>
>>>>>> I guess if someone asks for both (1) and (3) we can do the fallbac=
k in the
>>>>>> kernel, like how we handle it right now.
>>>>>>
>>>>>
>>>>> I think we should focus on what the actual legit use cases might be=
=2E
>>>>> Certainly we want to support a mode that's "reflink or fail".  We
>>>>> could have these flags:
>>>>>
>>>>> COPY_FILE_RANGE_ALLOW_REFLINK
>>>>> COPY_FILE_RANGE_ALLOW_COPY
>>>>>
>>>>> Setting neither gets -EINVAL.  Setting both works as is.  Setting j=
ust
>>>>> ALLOW_REFLINK will fail if a reflink can't be supported.  Setting j=
ust
>>>>> ALLOW_COPY will make a best-effort attempt not to reflink but
>>>>> expressly permits reflinking in cases where either (a) plain old
>>>>> write(2) might also result in a reflink or (b) there is no advantag=
e
>>>>> to not reflinking.
>>>>
>>>> I don't agree with having a 'copy' flag that can reflink when we als=
o have a
>>>> 'reflink' flag.  I guess I just don't like having a flag with differ=
ent
>>>> meanings depending on context.
>>>>
>>>> Users should be able to get the default behavior by passing '0' for =
flags, so
>>>> provide FORBID_REFLINK and FORBID_COPY flags to turn off those behav=
iors, with
>>>> an admonishment that one should only use them if they have a goooood=
 reason.
>>>> Passing neither gets you reflink-xor-copy, which is what I think we =
both want
>>>> in the general case.
>>>
>>> I agree here that 0 for flags should do something useful, and I wante=
d to
>>> double check if reflink-xor-copy is a good default behavior.
>>
>> Ok.
>>
>>>>
>>>> FORBID_REFLINK =3D 1
>>>> FORBID_COPY =3D 2
>>>
>>> I don't like the idea of using flags to forbid behavior.  I think it =
would be
>>> more straightforward to have flags like REFLINK_ONLY or COPY_ONLY so =
users
>>> can tell us what they want, instead of what they don't want.
>>
>> Seems fine to me.
>>
>>> While I'm thinking about flags, COPY_FILE_RANGE_REFLINK_ONLY would be=
 a bit
>>> of a mouthful.  Does anybody have suggestions for ways that I could m=
ake this
>>> shorter?
>>
>> CFR_REFLINK_ONLY?
>
> That could work!  Although I might do as Austin suggests and drop the _=
ONLY part, and then make the man page clear about what's going on.
>
> Would you expect to trigger a NFS server side copy by passing the pagec=
ache copy flag?  Or would that only happen if I pass flags=3D0?
Personally, I would think that an NFS server side copy could be counted=20
under the 'hardware assisted' flag.  From the point of view of an NFS=20
client, the NFS server is a (usually) opaque piece of storage hardware,=20
similar to a local disk drive in that you pass commands to it and get=20
responses, the only real difference is that NFS is a much higher level=20
protocol than for example SCSI.
>>
>> --D
>>
>>>
>>> Thanks,
>>> Anna
>>>
>>>> CHECK_SAME =3D 4
>>>> HW_COPY =3D 8
>>>>
>>>> DEDUPE =3D (FORBID_COPY | CHECK_SAME)
>>>>
>>>> What do you say to that?
>>>>
>>>>> An example of (b) would be a filesystem backed by deduped
>>>>> thinly-provisioned storage that can't do anything about ENOSPC beca=
use
>>>>> it doesn't control it in the first place.
>>>>>
>>>>> Another option would be to split up the copy case into "I expect to=

>>>>> overwrite a lot of the target file soon, so (c) try to commit space=

>>>>> for that or (d) try to make it time-efficient".  Of course, (d) is
>>>>> irrelevant on filesystems with no random access (nvdimms, for
>>>>> example).
>>>>>
>>>>> I guess the tl;dr is that I'm highly skeptical of any use for
>>>>> disallowing reflinking other than forcibly committing space in case=
s
>>>>> where committing space actually means something.
>>>>
>>>> That's more or less where I was going too. :)
>>>>
>>>> --D
>>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-api" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



--------------ms040407030204040002010202
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgMFADCABgkqhkiG9w0BBwEAAKCC
Brgwgga0MIIEnKADAgECAgMQblUwDQYJKoZIhvcNAQENBQAweTEQMA4GA1UEChMHUm9vdCBD
QTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNp
Z25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcwHhcN
MTUwMzI1MTkzNDM4WhcNMTUwOTIxMTkzNDM4WjBjMRgwFgYDVQQDEw9DQWNlcnQgV29UIFVz
ZXIxIzAhBgkqhkiG9w0BCQEWFGFoZmVycm9pbjdAZ21haWwuY29tMSIwIAYJKoZIhvcNAQkB
FhNhaGVtbWVsZ0BvaGlvZ3QuY29tMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
nQ/81tq0QBQi5w316VsVNfjg6kVVIMx760TuwA1MUaNQgQ3NyUl+UyFtjhpkNwwChjgAqfGd
LIMTHAdObcwGfzO5uI2o1a8MHVQna8FRsU3QGouysIOGQlX8jFYXMKPEdnlt0GoQcd+BtESr
pivbGWUEkPs1CwM6WOrs+09bAJP3qzKIr0VxervFrzrC5Dg9Rf18r9WXHElBuWHg4GYHNJ2V
Ab8iKc10h44FnqxZK8RDN8ts/xX93i9bIBmHnFfyNRfiOUtNVeynJbf6kVtdHP+CRBkXCNRZ
qyQT7gbTGD24P92PS2UTmDfplSBcWcTn65o3xWfesbf02jF6PL3BCrVnDRI4RgYxG3zFBJuG
qvMoEODLhHKSXPAyQhwZINigZNdw5G1NqjXqUw+lIqdQvoPijK9J3eijiakh9u2bjWOMaleI
SMRR6XsdM2O5qun1dqOrCgRkM0XSNtBQ2JjY7CycIx+qifJWsRaYWZz0aQU4ZrtAI7gVhO9h
pyNaAGjvm7PdjEBiXq57e4QcgpwzvNlv8pG1c/hnt0msfDWNJtl3b6elhQ2Pz4w/QnWifZ8E
BrFEmjeeJa2dqjE3giPVWrsH+lOvQQONsYJOuVb8b0zao4vrWeGmW2q2e3pdv0Axzm/60cJQ
haZUv8+JdX9ZzqxOm5w5eUQSclt84u+D+hsCAwEAAaOCAVkwggFVMAwGA1UdEwEB/wQCMAAw
VgYJYIZIAYb4QgENBEkWR1RvIGdldCB5b3VyIG93biBjZXJ0aWZpY2F0ZSBmb3IgRlJFRSBo
ZWFkIG92ZXIgdG8gaHR0cDovL3d3dy5DQWNlcnQub3JnMA4GA1UdDwEB/wQEAwIDqDBABgNV
HSUEOTA3BggrBgEFBQcDBAYIKwYBBQUHAwIGCisGAQQBgjcKAwQGCisGAQQBgjcKAwMGCWCG
SAGG+EIEATAyBggrBgEFBQcBAQQmMCQwIgYIKwYBBQUHMAGGFmh0dHA6Ly9vY3NwLmNhY2Vy
dC5vcmcwMQYDVR0fBCowKDAmoCSgIoYgaHR0cDovL2NybC5jYWNlcnQub3JnL3Jldm9rZS5j
cmwwNAYDVR0RBC0wK4EUYWhmZXJyb2luN0BnbWFpbC5jb22BE2FoZW1tZWxnQG9oaW9ndC5j
b20wDQYJKoZIhvcNAQENBQADggIBABr5e8W+NiTER+Q/7wiA2LxWN3UdhT3eZJjqqSlP370P
KL5iWqeTfxQ67Ai/mHbJcT2PgAJ+/D2Ji+aRR03UWnU/vtOwzyDLUMstqnfl0Zs+sz/CJe7x
nBA5jlpjC2DKuMVfbPze7eySaen7XSGFHKE1QoVIIpQ2kVjC4nbbJQnUbAVX1Iz29WxeVGt9
XYigz3tDPf3tglN+q23E7YjQl4abTIoM7i98yV1H9gfY8lFfKZ6jREB9+n6ie2EwS3Kat2mG
tl2wBx4MfRnoSQSKsLKQ5oTwhWf0JqlFwpLfl374p0Njcykej9/jnWG8Ks1V/AXTHqI4eyIP
Mf5yMZkPv7n7LS9WWKdG4Nd38iv4T2EiAaWsmgu+r81qL5CJu9AyA0SBS4ttKf6k3e63w2Mv
N9R45vpQ3QhAhfWyFxFhZN95APe3YECDG3+XIRJpRYPEtHuIsOyzI70ajF93gg/BidvqKsmV
MM2ccktDMfqwZXea6zey7F8Geu9R7BqjXmG2HlNuXu7e/xnHOgXf5D3wPmnRLlBhXL1Ch97a
w2KjaupjpAHfFjv5kGnZXN87UvvlwzIZiKXwa3vTDwK+rrKn/sHPkfDZPSiyt/ZBIK6lX83P
34H/CzGg+Kx57rHYOIHGumIvpDa5vfWp8O0sGgawb1C2Aae4sTUVIWmIjVuGI062MYIE0TCC
BM0CAQEwgYAweTEQMA4GA1UEChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNl
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxBuVTANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwOTEwMTU0OTIwWjBPBgkq
hkiG9w0BCQQxQgRAs/bhnb3U3WLxLpDx/KqJdf0aPc3Kc0IYEF3TdR6UeyhArNdcMwM1ZVAG
sGLUzqlyGt/YZJhd95B7zJmlBz50zzBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxBuVTCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxBuVTAN
BgkqhkiG9w0BAQEFAASCAgCY/kOY3+5UAJZOsMxRPJxvVViEUg8uHR0pSwl68MLrKsK5aTgl
Pn93dOD2+kYpwI/GtL18u29k0K2Ycndf0RwuNa9xhQ3O1vCJaVIHvoe4+/4SaiTrfmz+t18n
n+FHvjeviYmmTk8Igx05h8cFXe10CLgI/l+npfgjVm/I+xYvwA9e+X7YLKXDD4KzKA41orn6
ez1kZR3eLeZ7GjFgcS6q7pgvciDQ3/x7IrqGZ+udfar5iyvAAkhuq8TifGZZH+I7ViGjOJQh
4V5JIR8L0gMJSPWV991Cxuz29xwZUpLnvsZdIWNBeG2ZrbZ6wBizsF/hEr09JtTqEixJDRoS
WedgTTYQHNEw3qO5wEjOtcza84A7Mti7o/VOgEH68B1m6YgaZ5Ua3zwQcnC3LZSZhBcmgDeg
JiQjeUBKD97SflV9OstvOqFweyk2Q4F3/I3Vu8CIdeVWdZnTE9oy7HRqrYFWxXPEcRgLYOpR
kDm+/LnK8WIemu+d7YD98pn/Ce4LoycdQPe++NdSooEGffR+YDqWSmwTaa+TsMLE66m1RAYm
S6tFuSPrpPLFwER5uWsVToagRDEiKxAGF2frEHjB+acSPFY6AKfnEglc+XO4djv8YmTdLDxa
LnYV2sgf+DJiT7IZlLmE/lHPgear9uAVpTaw4hb15Jh5q4tNs65Wp77aHwAAAAAAAA==
--------------ms040407030204040002010202--
