Return-Path: <nfsv4-bounces@ietf.org>
From: Thomas Haynes <thomas@netapp.com>
In-Reply-To: <op.vjabhlntrwwil4@sfaibish1.corp.emc.com>
Date: Mon, 20 Sep 2010 11:19:30 -0500
Message-Id: <CAD787A2-E432-4EB3-9725-70A5FBD0EE55@netapp.com>
References: <op.vi7c6cmorwwil4@sfaibish1.corp.emc.com>
	<4C961A50.5010000@panasas.com>
	<op.vjabhlntrwwil4@sfaibish1.corp.emc.com>
To: Sorin Faibish <sfaibish@emc.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Peter Honeyman <Honey@citi.umich.edu>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>, Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [nfsv4] Discussion topics for the coming Bake-A-Thon
List-Unsubscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============0863728073=="
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============0863728073==
Content-Type: multipart/alternative; boundary=Apple-Mail-13--397790676

--Apple-Mail-13--397790676
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

=20
On Sep 19, 2010, at 9:49 AM, Sorin Faibish wrote:

> On Sun, 19 Sep 2010 10:12:32 -0400, Boaz Harrosh =
<bharrosh@panasas.com> wrote:
>=20
>> On 09/18/2010 02:33 AM, Sorin Faibish wrote:
>>>=20
>>> 5. Extend cthon tests with callback operations tests (Peter =
Honeyman)
>>=20
>>     And local/remote truncate torture tests.
> Sure. Do we need a separate discussion or only this?
>=20
>>=20
>>> 6. Performance tests - tools and benchmarks (Peter Honeyman)
>>=20
>> to 6 or 5. Cluster tests. .i.e use of more then one client in =
concertration
>> to confuse and crash a server.
> This aside from cthon, just for performance qaulification for the git.
> Same do we need an additional spot or this is enough (30 min).
>=20
> I will update the agenda with your comments and I assume you will be
> part of the discussion, even drive it.
>=20
> /Sorin
>=20


One subject I would like to see us address as a community is where we go
with respect to our general testing strategy. We have had discussions =
the
last several years at the Connectathons about the ability to contribute =
to the
cthon test suites and the legal status of the code.

Basically, because of the lack of understanding of the licensing, I =
believe
companies are not contributing changes back into the shared code base.

We can talk about what it would take to get the license straightened =
out,
but it might be more expedient to acknowledge that the cthon test suite =
is
a low bar and drive the creation of a new test suite.


--Apple-Mail-13--397790676
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
></head><body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; -we=
bkit-line-break: after-white-space; ">&nbsp;<br><div><div>On Sep 19, 2010, =
at 9:49 AM, Sorin Faibish wrote:</div><br class=3D"Apple-interchange-newlin=
e"><blockquote type=3D"cite"><div>On Sun, 19 Sep 2010 10:12:32 -0400, Boaz =
Harrosh &lt;<a href=3D"mailto:bharrosh@panasas.com">bharrosh@panasas.com</a=
>&gt; wrote:<br><br><blockquote type=3D"cite">On 09/18/2010 02:33 AM, Sorin=
 Faibish wrote:<br></blockquote><blockquote type=3D"cite"><blockquote type=
=3D"cite"><br></blockquote></blockquote><blockquote type=3D"cite"><blockquo=
te type=3D"cite">5. Extend cthon tests with callback operations tests (Pete=
r Honeyman)<br></blockquote></blockquote><blockquote type=3D"cite"><br></bl=
ockquote><blockquote type=3D"cite"> &nbsp;&nbsp;&nbsp;&nbsp;And local/remot=
e truncate torture tests.<br></blockquote>Sure. Do we need a separate discu=
ssion or only this?<br><br><blockquote type=3D"cite"><br></blockquote><bloc=
kquote type=3D"cite"><blockquote type=3D"cite">6. Performance tests - tools=
 and benchmarks (Peter Honeyman)<br></blockquote></blockquote><blockquote t=
ype=3D"cite"><br></blockquote><blockquote type=3D"cite">to 6 or 5. Cluster =
tests. .i.e use of more then one client in concertration<br></blockquote><b=
lockquote type=3D"cite">to confuse and crash a server.<br></blockquote>This=
 aside from cthon, just for performance qaulification for the git.<br>Same =
do we need an additional spot or this is enough (30 min).<br><br>I will upd=
ate the agenda with your comments and I assume you will be<br>part of the d=
iscussion, even drive it.<br><br>/Sorin<br><font class=3D"Apple-style-span"=
 color=3D"#006312"><br></font></div></blockquote><br></div><div><br></div><=
div>One subject I would like to see us address as a community is where we g=
o</div><div>with respect to our general testing strategy. We have had discu=
ssions the</div><div>last several years at the Connectathons about the abil=
ity to contribute to the</div><div>cthon test suites and the legal status o=
f the code.</div><div><br></div><div>Basically, because of the lack of unde=
rstanding of the licensing, I believe</div><div>companies are not contribut=
ing changes back into the shared code base.</div><div><br></div><div>We can=
 talk about what it would take to get the license straightened out,</div><d=
iv>but it might be more expedient to acknowledge that the cthon test suite =
is</div><div>a low bar and drive the creation of a new test suite.</div><br=
></body></html>=

--Apple-Mail-13--397790676--

--===============0863728073==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

--===============0863728073==--
