From: Anand Avati <anand.avati@gmail.com>
Subject: Re: regressions due to 64-bit ext4 directory cookies
Date: Thu, 28 Mar 2013 15:20:59 -0700
Message-ID: <CAFboF2y3Md2e6xiWq1sp2Zs-3dX3U=6oWLx_JVx9Pte7cRX1YQ@mail.gmail.com>
References: <20130213224720.GE5938@thunk.org>
	<CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com>
	<20130213230511.GW14195@fieldses.org>
	<20130213234430.GF5938@thunk.org>
	<CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com>
	<5151BD5F.30607@itwm.fraunhofer.de> <5151C33E.2070008@redhat.com>
	<20130328140744.GA4989@thunk.org>
	<20130328175205.GD16651@lenny.home.zabbo.net>
	<CAFboF2ztc06G00z8ga35NrxgnT2YgBiDECgU_9kvVA_Go1_Bww@mail.gmail.com>
	<20130328183153.GG7080@fieldses.org>
	<CAFboF2w49Lc0vM0SerbJfL9_RuSHgEU+y_Yk7F4pLxeiqu+KRg@mail.gmail.com>
	<51549D74.1060703@redhat.com>
	<CAFboF2xkvXx9YFYxBXupwg=s=3MaeQYm2KK2m8MFtEBPsxwQ7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8110946275589804602=="
Cc: Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org,
	Theodore Ts'o <tytso@mit.edu>, Zach Brown <zab@redhat.com>,
	Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
	linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
To: Jeff Darcy <jdarcy@redhat.com>
Return-path: <gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org>
In-Reply-To: <CAFboF2xkvXx9YFYxBXupwg=s=3MaeQYm2KK2m8MFtEBPsxwQ7Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/gluster-devel>,
	<mailto:gluster-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/gluster-devel>
List-Post: <mailto:gluster-devel@nongnu.org>
List-Help: <mailto:gluster-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/gluster-devel>,
	<mailto:gluster-devel-request@nongnu.org?subject=subscribe>
Errors-To: gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org
Sender: gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org
List-ID: <linux-nfs.vger.kernel.org>

--===============8110946275589804602==
Content-Type: multipart/alternative; boundary=e89a8ff1c1fcb375de04d9039149

--e89a8ff1c1fcb375de04d9039149
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Mar 28, 2013 at 3:14 PM, Anand Avati <anand.avati@gmail.com> wrote:

> On Thu, Mar 28, 2013 at 12:43 PM, Jeff Darcy <jdarcy@redhat.com> wrote:
>
>> On 03/28/2013 02:49 PM, Anand Avati wrote:
>> > Yes, it should, based on the theory of how ext4 was generating the
>> > 63bits. But Jeff's test finds that the experiment is not matching the
>> > theory.
>>
>> FWIW, I was able to re-run my test in between stuff related to That
>> Other Problem.  What seems to be happening is that we read correctly
>> until just after d_off 0x4000000000000000, then we suddenly wrap around
>> - not to the very first d_off we saw, but to a pretty early one (e.g.
>> 0x0041b6340689a32e).  This is all on a single brick, BTW, so it's pretty
>> easy to line up the back-end and front-end d_off values which match
>> perfectly up to this point.
>>
>> I haven't had a chance to ponder what this all means and debug it
>> further.  Hopefully I'll be able to do so soon, but I figured I'd
>> mention it in case something about those numbers rang a bell.
>>
>
> Of course, the unit tests (with artificial offsets) were done with brick
> count >= 2. You have tested with DHT subvol count=1, which was not tested,
> and sure enough, the code isn't handling it well. Just verified with the
> unit tests that brick count = 1 condition fails to return the same d_off.
>
> Posting a fixed version. Thanks for the catch!
>

Posted an updated version http://review.gluster.org/4711. This passes unit
tests for all brick counts (>= 1). Can you confirm if the "loop"ing is now
gone in your test env?

Thanks,
Avati

--e89a8ff1c1fcb375de04d9039149
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Mar 28, 2013 at 3:14 PM, Anand A=
vati <span dir=3D"ltr">&lt;<a href=3D"mailto:anand.avati@gmail.com" target=
=3D"_blank">anand.avati@gmail.com</a>&gt;</span> wrote:<br><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex">
On Thu, Mar 28, 2013 at 12:43 PM, Jeff Darcy <span dir=3D"ltr">&lt;<a href=
=3D"mailto:jdarcy@redhat.com" target=3D"_blank">jdarcy@redhat.com</a>&gt;</=
span> wrote:<br><div class=3D"gmail_quote"><div><div class=3D"h5"><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex">

<div>On 03/28/2013 02:49 PM, Anand Avati wrote:<br>
&gt; Yes, it should, based on the theory of how ext4 was generating the<br>
&gt; 63bits. But Jeff&#39;s test finds that the experiment is not matching =
the<br>
&gt; theory.<br>
<br>
</div>FWIW, I was able to re-run my test in between stuff related to That<b=
r>
Other Problem. =A0What seems to be happening is that we read correctly<br>
until just after d_off 0x4000000000000000, then we suddenly wrap around<br>
- not to the very first d_off we saw, but to a pretty early one (e.g.<br>
0x0041b6340689a32e). =A0This is all on a single brick, BTW, so it&#39;s pre=
tty<br>
easy to line up the back-end and front-end d_off values which match<br>
perfectly up to this point.<br>
<br>
I haven&#39;t had a chance to ponder what this all means and debug it<br>
further. =A0Hopefully I&#39;ll be able to do so soon, but I figured I&#39;d=
<br>
mention it in case something about those numbers rang a bell.<br></blockquo=
te><div><br></div></div></div><div>Of course, the unit tests (with artifici=
al offsets) were done with brick count &gt;=3D 2. You have tested with DHT =
subvol count=3D1, which was not tested, and sure enough, the code isn&#39;t=
 handling it well. Just verified with the unit tests that brick count =3D 1=
 condition fails to return the same d_off.</div>

<div><br></div><div>Posting a fixed version. Thanks for the catch!</div></d=
iv></blockquote><div><br></div><div>Posted an updated version <a href=3D"ht=
tp://review.gluster.org/4711">http://review.gluster.org/4711</a>. This pass=
es unit tests for all brick counts (&gt;=3D 1). Can you confirm if the &quo=
t;loop&quot;ing is now gone in your test env?</div>
<div><br></div><div>Thanks,</div><div>Avati</div><div>=A0</div></div>

--e89a8ff1c1fcb375de04d9039149--


--===============8110946275589804602==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Gluster-devel mailing list
Gluster-devel@nongnu.org
https://lists.nongnu.org/mailman/listinfo/gluster-devel

--===============8110946275589804602==--
