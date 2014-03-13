Return-Path: nfsv4-bounces@ietf.org
In-Reply-To: <CAK1qKt+wf9WV1t0LPcM89a8ifyQ5j=y60eoY4DjHoqdF-FbUyQ@mail.gmail.com>
References: <CAK1qKt+wf9WV1t0LPcM89a8ifyQ5j=y60eoY4DjHoqdF-FbUyQ@mail.gmail.com>
From: Benny Halevy <bhalevy@primarydata.com>
Date: Fri, 14 Mar 2014 01:56:44 +0200
Message-ID: <CAEMWVhtOJdwg8-bu2Hm6tXCNgV3d-PVnrPN-i-SOUHU8GAh7mA@mail.gmail.com>
To: Michael Maymann <michael@maymann.org>,
        NFS list <linux-nfs@vger.kernel.org>
Cc: "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: [nfsv4] PNFS questions
List-Unsubscribe: <https://www.ietf.org/mailman/options/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4/>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============7030815886579866100=="
Errors-To: nfsv4-bounces@ietf.org
Sender: "nfsv4" <nfsv4-bounces@ietf.org>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============7030815886579866100==
Content-Type: multipart/alternative; boundary=047d7bf0e158ce420a04f485b505

--047d7bf0e158ce420a04f485b505
Content-Type: text/plain; charset=ISO-8859-1

Michael, the IETF mailing list is really not the right place to ask about
commercial solutions in general or linux solutions in particular.
Cc'ing the linux-nfs mailing list. Comments in line below.


On Thu, Mar 13, 2014 at 9:02 PM, Michael Maymann <michael@maymann.org>wrote:

> Hi list,
>
> I'm setting up a new BIO-HPC facility and are looking for a fault
> tolerant, scalable, fast and priceeffective storage solution.
>
> I have been looking at Coraid, Panasas and Lustre, but would like to
> investigate my options also of building my own PNFS solution. Clients are
> all Debian based.
>
> Can anyone recommend:
> 1. If PNFS is ready for production or if I should stick with a commercial
> vendor or build a Lustre solution ?
>

There is no pNFS server implementation in upstream linux yet.
We maintain a development out-of-kernel tree in git://
linux-nfs.org/~bhalevy/linux-pnfs.git
but it is not production ready.


> 2. PNFS Metadata server SW prefferably for Debian ?
>

ditto #1


>  3. PNFS Diskshelfs to be used ?
>

In pNFS terminology, these are Data Servers.


>  4. If AOE (ATA Over Ethernet) would make any sense together with PNFS ?
>

Maybe using the Block layout and AoE as the block storage transport
protocol.


>  5. PNFS GUI SW prefferably for Debian ?
>

ditto #1



> Thanks in advance :-) !
>
> BR.
> ~Maymann
>
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
>
>

--047d7bf0e158ce420a04f485b505
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1"><div dir=3D"ltr"><div>Michael, the IETF mailing list is really not the r=
ight place to ask about commercial solutions in general or linux solutions =
in particular.<br></div>Cc'ing the linux-nfs mailing list. Comments in line=
 below.<br>

<div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote">On Thu, Mar 1=
3, 2014 at 9:02 PM, Michael Maymann <span dir=3D"ltr">&lt;<a href=3D"mailto=
:michael@maymann.org" target=3D"_blank">michael@maymann.org</a>&gt;</span> =
wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><p dir=3D"ltr">Hi list,</p>
<p dir=3D"ltr">I'm setting up a new BIO-HPC facility and are looking for a =
fault tolerant, scalable, fast and priceeffective storage solution.</p>
<p dir=3D"ltr">I have been looking at Coraid, Panasas and Lustre, but would=
 like to investigate my options also of building my own PNFS solution. Clie=
nts are all Debian based.</p>
<p dir=3D"ltr">Can anyone recommend:<br>
1. If PNFS is ready for production or if I should stick with a commercial v=
endor or build a Lustre solution ?<br></p></blockquote><div><br></div><div>=
There is no pNFS server implementation in upstream linux yet.<br></div>

<div>We maintain a development out-of-kernel tree in git://<a href=3D"http:=
//linux-nfs.org/~bhalevy/linux-pnfs.git">linux-nfs.org/~bhalevy/linux-pnfs.=
git</a><br></div><div>but it is not production ready.<br></div><div>&nbsp;<=
/div>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><p dir=3D"ltr">
2. PNFS Metadata server SW prefferably for Debian ?<br></p></blockquote><di=
v><br></div><div>ditto #1<br></div><div>&nbsp;</div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex">

<p dir=3D"ltr">
3. PNFS Diskshelfs to be used ?<br></p></blockquote><div><br>In pNFS termin=
ology, these are Data Servers.<br></div><div>&nbsp;</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">

<p dir=3D"ltr">
4. If AOE (ATA Over Ethernet) would make any sense together with PNFS ?<br>=
</p></blockquote><div><br></div><div>Maybe using the Block layout and AoE a=
s the block storage transport protocol.<br></div><div>&nbsp;</div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex">

<p dir=3D"ltr">
5. PNFS GUI SW prefferably for Debian ?</p></blockquote><div><br></div><div=
>ditto #1<br><br></div><div></div><div></div><div>&nbsp;</div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex">


<p dir=3D"ltr">Thanks in advance :-) !</p>
<p dir=3D"ltr">BR.<span class=3D"HOEnZb"><font color=3D"#888888"><br>
~Maymann</font></span></p>
<br>_______________________________________________<br>
nfsv4 mailing list<br>
<a href=3D"mailto:nfsv4@ietf.org">nfsv4@ietf.org</a><br>
<a href=3D"https://www.ietf.org/mailman/listinfo/nfsv4" target=3D"_blank">h=
ttps://www.ietf.org/mailman/listinfo/nfsv4</a><br>
<br></blockquote></div><br></div></div>

--047d7bf0e158ce420a04f485b505--

--===============7030815886579866100==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

--===============7030815886579866100==--
