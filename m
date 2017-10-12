Return-Path: nfsv4-bounces@ietf.org
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20171012120814.GB5957@stefanha-x1.localdomain>
Date: Thu, 12 Oct 2017 12:40:20 -0400
Message-Id: <D5A0AD89-0FA0-4057-849D-57BA54433710@gmail.com>
References: <20171005200835.GA31525@stefanha-x1.localdomain>
 <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com>
 <20171012120814.GB5957@stefanha-x1.localdomain>
To: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [nfsv4] Draft RFC for ONC RPC over AF_VSOCK
List-Unsubscribe: <https://www.ietf.org/mailman/options/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <https://mailarchive.ietf.org/arch/browse/nfsv4/>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=subscribe>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>, NFSv4 <nfsv4@ietf.org>
Content-Type: multipart/mixed; boundary="===============9198866999815791686=="
Errors-To: nfsv4-bounces@ietf.org
Sender: "nfsv4" <nfsv4-bounces@ietf.org>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============9198866999815791686==
Content-Type: multipart/alternative;
 boundary=Apple-Mail-1D611ACA-1783-4A07-84AA-7DFC05FC0943
Content-Transfer-Encoding: 7bit

--Apple-Mail-1D611ACA-1783-4A07-84AA-7DFC05FC0943
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable



> On Oct 12, 2017, at 8:08 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
>=20
>> On Thu, Oct 05, 2017 at 04:50:55PM -0400, Matt Benjamin wrote:
>>> On Thu, Oct 5, 2017 at 4:08 PM, Stefan Hajnoczi <stefanha@redhat.com> wr=
ote:
>>> I have previously submitted patches that implement NFS client and nfsd
>>> support for the AF_VSOCK address family.  In order for this to be
>>> acceptable for merge the AF_VSOCK transport needs to be defined in an
>>> IETF RFC.  Below is a draft RFC that defines ONC RPC over AF_VSOCK.
>>>=20
>>> My patches use netid "vsock" but "tcpv" has also been suggested.  This d=
raft
>>> RFC still uses "vsock" but I'll update it to "tcpv" if there is consensu=
s.
>>>=20
>>=20
>> I think "vsock" is the appropriate netid, not "tcpv."  Stream
>> orientation, if anything, is the general category containing TCP and
>> VSOCK, not the reverse.  But really I think it's just more clear.
>>=20
>> I think this draft needs to be sent to the IETF NFSv4 working group
>> alias, nfsv4@ietf.org.
>=20
> Thanks.  Will send the next revision properly formatted to the NFSv4
> working group.

Don=E2=80=99t do that. Please submit a personal draft via:

https://datatracker.ietf.org/submit/

once you have appropriate permission from RH legal
counsel to contribute to the IETF. Then approach the
working group to introduce your submitted document.

Thanks!=

--Apple-Mail-1D611ACA-1783-4A07-84AA-7DFC05FC0943
Content-Type: text/html;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html><head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dutf-8"></=
head><body dir=3D"auto"><br><div><br>On Oct 12, 2017, at 8:08 AM, Stefan Ha=
jnoczi &lt;<a href=3D"mailto:stefanha@redhat.com">stefanha@redhat.com</a>&g=
t; wrote:<br><br></div><blockquote type=3D"cite"><div><span>On Thu, Oct 05,=
 2017 at 04:50:55PM -0400, Matt Benjamin wrote:</span><br><blockquote type=
=3D"cite"><span>On Thu, Oct 5, 2017 at 4:08 PM, Stefan Hajnoczi &lt;<a href=
=3D"mailto:stefanha@redhat.com">stefanha@redhat.com</a>&gt; wrote:</span><b=
r></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><span>I =
have previously submitted patches that implement NFS client and nfsd</span>=
<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D=
"cite"><span>support for the AF_VSOCK address family. &nbsp;In order for th=
is to be</span><br></blockquote></blockquote><blockquote type=3D"cite"><blo=
ckquote type=3D"cite"><span>acceptable for merge the AF_VSOCK transport nee=
ds to be defined in an</span><br></blockquote></blockquote><blockquote type=
=3D"cite"><blockquote type=3D"cite"><span>IETF RFC. &nbsp;Below is a draft =
RFC that defines ONC RPC over AF_VSOCK.</span><br></blockquote></blockquote=
><blockquote type=3D"cite"><blockquote type=3D"cite"><span></span><br></blo=
ckquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><s=
pan>My patches use netid &quot;vsock&quot; but &quot;tcpv&quot; has also be=
en suggested. &nbsp;This draft</span><br></blockquote></blockquote><blockqu=
ote type=3D"cite"><blockquote type=3D"cite"><span>RFC still uses &quot;vsoc=
k&quot; but I'll update it to &quot;tcpv&quot; if there is consensus.</span=
><br></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=
=3D"cite"><span></span><br></blockquote></blockquote><blockquote type=3D"ci=
te"><span></span><br></blockquote><blockquote type=3D"cite"><span>I think &=
quot;vsock&quot; is the appropriate netid, not &quot;tcpv.&quot; &nbsp;Stre=
am</span><br></blockquote><blockquote type=3D"cite"><span>orientation, if a=
nything, is the general category containing TCP and</span><br></blockquote>=
<blockquote type=3D"cite"><span>VSOCK, not the reverse. &nbsp;But really I =
think it's just more clear.</span><br></blockquote><blockquote type=3D"cite=
"><span></span><br></blockquote><blockquote type=3D"cite"><span>I think thi=
s draft needs to be sent to the IETF NFSv4 working group</span><br></blockq=
uote><blockquote type=3D"cite"><span>alias, <a href=3D"mailto:nfsv4@ietf.or=
g">nfsv4@ietf.org</a>.</span><br></blockquote><span></span><br><span>Thanks=
. &nbsp;Will send the next revision properly formatted to the NFSv4</span><=
br><span>working group.</span><br></div></blockquote><div><br></div><div>Do=
n=E2=80=99t do that. Please submit a personal draft via:</div><div><br></di=
v><div><a href=3D"https://datatracker.ietf.org/submit/">https://datatracker=
.ietf.org/submit/</a></div><div><br></div><div>once you have appropriate pe=
rmission from RH legal</div><div>counsel to contribute to the IETF. Then ap=
proach the</div><div>working group to introduce your submitted document.</d=
iv><div><br></div><div>Thanks!</div></body></html>=

--Apple-Mail-1D611ACA-1783-4A07-84AA-7DFC05FC0943--

--===============9198866999815791686==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

--===============9198866999815791686==--
