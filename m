From: Anand Avati <anand.avati@gmail.com>
Subject: Re: regressions due to 64-bit ext4 directory cookies
Date: Thu, 28 Mar 2013 11:49:36 -0700
Message-ID: <CAFboF2w49Lc0vM0SerbJfL9_RuSHgEU+y_Yk7F4pLxeiqu+KRg@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1773639004856893358=="
Cc: Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org,
	Theodore Ts'o <tytso@mit.edu>, Zach Brown <zab@redhat.com>,
	Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
	linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org>
In-Reply-To: <20130328183153.GG7080@fieldses.org>
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

--===============1773639004856893358==
Content-Type: multipart/alternative; boundary=001a11c1d64cbe531304d9009db5

--001a11c1d64cbe531304d9009db5
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Mar 28, 2013 at 11:31 AM, J. Bruce Fields <bfields@fieldses.org>wrote:
>
> > Jeff reported that the approach did not work in his testing. I haven't
> had
> > a chance to look into the failure yet. Independent of the fix, it would
> > certainly be good have the ioctl() support
>
> The one advantage of your scheme is that it keeps more of the hash bits;
> the chance of 31-bit cookie collisions is much higher.


Yes, it should, based on the theory of how ext4 was generating the 63bits.
But Jeff's test finds that the experiment is not matching the theory. I
intend to debug this, but currently drowned in a different issue. It would
be good if the ext developers can have a look at
http://review.gluster.org/4711 and see if there are obvious holes in the
approach or code.

Avati

--001a11c1d64cbe531304d9009db5
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Mar 28, 2013 at 11:31 AM, J. Bru=
ce Fields <span dir=3D"ltr">&lt;<a href=3D"mailto:bfields@fieldses.org" tar=
get=3D"_blank">bfields@fieldses.org</a>&gt;</span> wrote:<blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5">
&gt; Jeff reported that the approach did not work in his testing. I haven&#=
39;t had<br>
&gt; a chance to look into the failure yet. Independent of the fix, it woul=
d<br>
&gt; certainly be good have the ioctl() support<br>
<br>
</div></div>The one advantage of your scheme is that it keeps more of the h=
ash bits;<br>
the chance of 31-bit cookie collisions is much higher.</blockquote><div><br=
></div><div>Yes, it should, based on the theory of how ext4 was generating =
the 63bits. But Jeff&#39;s test finds that the experiment is not matching t=
he theory. I intend to debug this, but currently drowned in a different iss=
ue. It would be good if the ext developers can have a look at <a href=3D"ht=
tp://review.gluster.org/4711">http://review.gluster.org/4711</a> and see if=
 there are obvious holes in the approach or code.</div>
<div><br></div><div>Avati</div><div><br></div></div>

--001a11c1d64cbe531304d9009db5--


--===============1773639004856893358==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Gluster-devel mailing list
Gluster-devel@nongnu.org
https://lists.nongnu.org/mailman/listinfo/gluster-devel

--===============1773639004856893358==--
