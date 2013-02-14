From: Anand Avati <anand.avati@gmail.com>
Subject: Re: regressions due to 64-bit ext4 directory cookies
Date: Wed, 13 Feb 2013 16:05:01 -0800
Message-ID: <CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com>
References: <20130213151455.GB17431@thunk.org>
	<20130213151953.GJ14195@fieldses.org>
	<20130213153654.GC17431@thunk.org>
	<20130213162059.GL14195@fieldses.org>
	<CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
	<20130213222052.GD5938@thunk.org>
	<20130213224141.GU14195@fieldses.org>
	<20130213224720.GE5938@thunk.org>
	<CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com>
	<20130213230511.GW14195@fieldses.org>
	<20130213234430.GF5938@thunk.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5388674227217865952=="
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
	linux-nfs@vger.kernel.org, sandeen@redhat.com,
	linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
To: "Theodore Ts'o" <tytso@mit.edu>
Return-path: <gluster-devel-bounces+gcfgd-gluster-devel=m.gmane.org@nongnu.org>
In-Reply-To: <20130213234430.GF5938-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
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

--===============5388674227217865952==
Content-Type: multipart/alternative; boundary=f46d0444edd393dc5f04d5a40293

--f46d0444edd393dc5f04d5a40293
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Feb 13, 2013 at 3:44 PM, Theodore Ts'o <tytso@mit.edu> wrote:
>
> I suspect this would seriously screw over Gluster, though, and this
> wouldn't be a solution for NFSv3, since NFS needs long-lived directory
> cookies, and not the short-lived cookies which is all POSIX/SuSv3
> guarantees.
>

Actually this would work just fine with Gluster. Except in the case of
gluster-NFS, the native client is only acting like a router/proxy of
syscalls to the backend system. A directory opened by an application will
have a matching directory fd opened on ext4, and readdir from an app will
be translated into readdir on the matching fd on ext4. So the
app-on-glusterfs and glusterfsd-on-ext4 are essentially "moving in tandem".
As long as the offs^H^H^H^H cookies do not overflow in the transformation,
Gluster would not have a problem.

However Gluster-NFS (and NFS in general, too) will break, as we
opendir/closedir potentially on every request.

Avati

--f46d0444edd393dc5f04d5a40293
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><div class=3D"gmail_quote">On Wed, Feb 13, 2013 at 3:44 PM, Theodore Ts=
&#39;o <span dir=3D"ltr">&lt;<a href=3D"mailto:tytso@mit.edu" target=3D"_bl=
ank">tytso@mit.edu</a>&gt;</span> wrote:<blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">

I suspect this would seriously screw over Gluster, though, and this<br>
wouldn&#39;t be a solution for NFSv3, since NFS needs long-lived directory<=
br>
cookies, and not the short-lived cookies which is all POSIX/SuSv3 guarantee=
s.<br></blockquote><div>=A0</div><div><div>Actually this would work just fi=
ne with Gluster. Except in the case of gluster-NFS, the native client is on=
ly acting like a router/proxy of syscalls to the backend system. A director=
y opened by an application will have a matching directory fd opened on ext4=
, and readdir from an app will be translated into readdir on the matching f=
d on ext4. So the app-on-glusterfs and glusterfsd-on-ext4 are essentially &=
quot;moving in tandem&quot;. As long as the offs^H^H^H^H cookies do not ove=
rflow in the transformation, Gluster would not have a problem.</div>
<div><br></div><div>However Gluster-NFS (and NFS in general, too) will brea=
k, as we opendir/closedir potentially on every request.</div></div><div><br=
></div><div>Avati</div></div>

--f46d0444edd393dc5f04d5a40293--


--===============5388674227217865952==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Gluster-devel mailing list
Gluster-devel@nongnu.org
https://lists.nongnu.org/mailman/listinfo/gluster-devel

--===============5388674227217865952==--
