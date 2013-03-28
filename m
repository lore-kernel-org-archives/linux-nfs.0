From: Anand Avati <anand.avati@gmail.com>
Subject: Re: regressions due to 64-bit ext4 directory cookies
Date: Thu, 28 Mar 2013 11:05:41 -0700
Message-ID: <CAFboF2ztc06G00z8ga35NrxgnT2YgBiDECgU_9kvVA_Go1_Bww@mail.gmail.com>
References: <20130213222052.GD5938@thunk.org>
	<20130213224141.GU14195@fieldses.org>
	<20130213224720.GE5938@thunk.org>
	<CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com>
	<20130213230511.GW14195@fieldses.org>
	<20130213234430.GF5938@thunk.org>
	<CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com>
	<5151BD5F.30607@itwm.fraunhofer.de> <5151C33E.2070008@redhat.com>
	<20130328140744.GA4989@thunk.org>
	<20130328175205.GD16651@lenny.home.zabbo.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1553705280663364187=="
Cc: Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org,
	Theodore Ts'o <tytso@mit.edu>,
	Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
	linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
To: Zach Brown <zab@redhat.com>
Return-path: <gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org>
In-Reply-To: <20130328175205.GD16651-fypN+1c5dIyjpB87vu3CluTW4wlIGRCZ@public.gmane.org>
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

--===============1553705280663364187==
Content-Type: multipart/alternative; boundary=e89a8f839d51a9093b04d9000075

--e89a8f839d51a9093b04d9000075
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Mar 28, 2013 at 10:52 AM, Zach Brown <zab@redhat.com> wrote:

> On Thu, Mar 28, 2013 at 10:07:44AM -0400, Theodore Ts'o wrote:
> > On Tue, Mar 26, 2013 at 10:48:14AM -0500, Eric Sandeen wrote:
> > > > We don't have reached a conclusion so far, do we? What about the
> > > > ioctl approach, but a bit differently? Would it work to specify the
> > > > allowed upper bits for ext4 (for example 16 additional bit) and the
> > > > remaining part for gluster? One of the mails had the calculation
> > > > formula:
> > >
> > > I did throw together an ioctl patch last week, but I think Anand has a
> new
> > > approach he's trying out which won't require ext4 code changes.  I'll
> let
> > > him reply when he has a moment.  :)
> >
> > Any update about whether Gluster can address this without needing the
> > ioctl patch?  Or should we push the ioctl patch into ext4 for the next
> > merge window?
>
> They're testing a work-around:
>
>   http://review.gluster.org/#change,4711
>
> I'm not sure if they've decided that they're going to go with it, or
> not.
>

Jeff reported that the approach did not work in his testing. I haven't had
a chance to look into the failure yet. Independent of the fix, it would
certainly be good have the ioctl() support - Samba could use it too, if it
wanted.

Avati

--e89a8f839d51a9093b04d9000075
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Mar 28, 2013 at 10:52 AM, Zach B=
rown <span dir=3D"ltr">&lt;<a href=3D"mailto:zab@redhat.com" target=3D"_bla=
nk">zab@redhat.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quot=
e" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5">On Thu, Mar 28, 2013 at 10:07:44AM =
-0400, Theodore Ts&#39;o wrote:<br>
&gt; On Tue, Mar 26, 2013 at 10:48:14AM -0500, Eric Sandeen wrote:<br>
&gt; &gt; &gt; We don&#39;t have reached a conclusion so far, do we? What a=
bout the<br>
&gt; &gt; &gt; ioctl approach, but a bit differently? Would it work to spec=
ify the<br>
&gt; &gt; &gt; allowed upper bits for ext4 (for example 16 additional bit) =
and the<br>
&gt; &gt; &gt; remaining part for gluster? One of the mails had the calcula=
tion<br>
&gt; &gt; &gt; formula:<br>
&gt; &gt;<br>
&gt; &gt; I did throw together an ioctl patch last week, but I think Anand =
has a new<br>
&gt; &gt; approach he&#39;s trying out which won&#39;t require ext4 code ch=
anges. =A0I&#39;ll let<br>
&gt; &gt; him reply when he has a moment. =A0:)<br>
&gt;<br>
&gt; Any update about whether Gluster can address this without needing the<=
br>
&gt; ioctl patch? =A0Or should we push the ioctl patch into ext4 for the ne=
xt<br>
&gt; merge window?<br>
<br>
</div></div>They&#39;re testing a work-around:<br>
<br>
=A0 <a href=3D"http://review.gluster.org/#change,4711" target=3D"_blank">ht=
tp://review.gluster.org/#change,4711</a><br>
<br>
I&#39;m not sure if they&#39;ve decided that they&#39;re going to go with i=
t, or<br>
not.<font color=3D"#888888"><br></font></blockquote><div><br></div><div>Jef=
f reported that the approach did not work in his testing. I haven&#39;t had=
 a chance to look into the failure yet. Independent of the fix, it would ce=
rtainly be good have the ioctl() support - Samba could use it too, if it wa=
nted.</div>
<div><br></div><div>Avati</div><div><br></div></div>

--e89a8f839d51a9093b04d9000075--


--===============1553705280663364187==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Gluster-devel mailing list
Gluster-devel@nongnu.org
https://lists.nongnu.org/mailman/listinfo/gluster-devel

--===============1553705280663364187==--
