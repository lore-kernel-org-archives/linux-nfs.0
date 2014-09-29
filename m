Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44271 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754383AbaI2VeZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2014 17:34:25 -0400
Date: Tue, 30 Sep 2014 07:34:15 +1000
From: NeilBrown <neilb@suse.de>
To: Benjamin ESTRABAUD <be@mpstor.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS auto-reconnect tuning.
Message-ID: <20140930073415.67256291@notabene.brown>
In-Reply-To: <54292F22.9050606@mpstor.com>
References: <5422E5CB.6000402@mpstor.com>
	<20140925114452.121776c0@notabene.brown>
	<5423E461.8020108@mpstor.com>
	<20140929092836.6de0fd92@notabene.brown>
	<54292F22.9050606@mpstor.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/kzNqN5BgbjG9rW9iv_Do4kx"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/kzNqN5BgbjG9rW9iv_Do4kx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 29 Sep 2014 11:06:26 +0100 Benjamin ESTRABAUD <be@mpstor.com> wrote:

> On 29/09/14 00:28, NeilBrown wrote:
> > On Thu, 25 Sep 2014 10:46:09 +0100 Benjamin ESTRABAUD <be@mpstor.com> w=
rote:
> >
> >> On 25/09/14 02:44, NeilBrown wrote:
> >>> On Wed, 24 Sep 2014 16:39:55 +0100 Benjamin ESTRABAUD <be@mpstor.com>=
 wrote:
> >>>
> >>>> Hi!
> >>>>
> >>>> I've got a scenario where I'm connected to a NFS share on a client, =
have
> >>>> a file descriptor open as read only (could also be write) on a file =
from
> >>>> that share, and I'm suddenly changing the IP address of that client.
> >>>>
> >>>> Obviously, the NFS share will hang, so if I now try to read the file
> >>>> descriptor I've got open (here in Python), the "read" call will also=
 hang.
> >>>>
> >>>> However, the driver seems to attempt to do something (maybe
> >>>> save/determine whether the existing connection can be saved) and the=
n,
> >>>> after about 20 minutes the driver transparently reconnects to the NFS
> >>>> share (which is what I wanted anyways) and the "read" call instantia=
ted
> >>>> earlier simply finishes (I don't even have to re-open the file again=
 or
> >>>> even call "read" again).
> >>>>
> >>>> The dmesg prints I get are as follow:
> >>>>
> >>>> [ 4424.500380] nfs: server 10.0.2.17 not responding, still trying <--
> >>>> changed IP address and started reading the file.
> >>>> [ 4451.560467] nfs: server 10.0.2.17 OK <--- The NFS share was
> >>>> reconnected, the "read" call completes successfully.
> >>>
> >>> The difference between these timestamps is 27 seconds, which is a lot=
 less
> >>> than the "20 minutes" that you quote.  That seems odd.
> >>>
> >> Hi Neil,
> >>
> >> My bad, I had made several attempts and must have copied the wrong dme=
sg
> >> trace. The above happened when I manually reverted the IP config back =
to
> >> its original address (when doing so the driver reconnects immediately).
> >>
> >> Here is what had happened:
> >>
> >> [ 1663.940406] nfs: server 10.0.2.17 not responding, still trying
> >> [ 2712.480325] nfs: server 10.0.2.17 OK
> >>
> >>> If you adjust
> >>>      /proc/sys/net/ipv4/tcp_retries2
> >>>
> >>> you can reduce the current timeout.
> >>> See Documentation/networking/ip-sysctl.txt for details on the setting.
> >>>
> >>> https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
> >>>
> >>> It claims the default gives an effective timeout of 924 seconds or ab=
out 15
> >>> minutes.
> >>>
> >>> I just tried and the timeout was 1047 seconds. This is probably the n=
ext
> >>> retry after 924 seconds.
> >>>
> >>> If I reduce tcp_retries2 to '3' (well below the recommended minimum) =
I get
> >>> a timeout of 5 seconds.
> >>> You can possibly find a suitable number that isn't too small...
> >>>
> >> That's very interesting! Thank you very much! However, I'm a bit worri=
ed
> >> when changing the whole TCP stack settings, NFS is only one small chunk
> >> of a much bigger network storage box, so if there are alternative it'll
> >> probably be better. Also I would need a very very small timeout, in the
> >> order of 10-20 secs *max* so that would probably cause other issues
> >> elsewhere, but this is very interesting indeed.
> >>
> >>> Alternately you could use NFSv4.  It will close the connection on a t=
imeout.
> >>> In the default config I measure a 78 second timeout, which is probabl=
y more
> >>> acceptable.  This number would respond to the timeo mount option.
> >>> If I set that to 100, I get a 28 second timeout.
> >>>
> >> This is great! I had no idea, I will definitely roll NFSv4 and try tha=
t.
> >> Thanks again for your help!
> >
> > Actually ... it turns out that NFSv4 shouldn't close the connection ear=
ly
> > like that.  It happens due to a bug which is now being fixed :-)
> Well, maybe I could "patch" NFSv4 here for my purpose or use the patch=20
> you provided before for NFSv3, although I admit it would be easier to=20
> use a stock kernel if possible.

You could.  Certainly safer to stick with stock kernel if possible (and we
appreciated the broader testing coverage!).

> >
> > Probably the real problem is that the TCP KEEPALIVE feature isn't worki=
ng
> > properly.  NFS configures it so that keep-alives are sent at the 'timeo=
ut'
> > time and the connection should close if a reply is not seen fairly soon.
> >
> I wouldn't mind using TCP Keepalives but I am worried that I'd have to=20
> change a TCP wide setting, which other applications might rely on (I=20
> read that the TCP keepalive time for instance should be no less than 2=20
> hours). Could NFS just have a "custom" TCP keepalive and leave the=20
> global, default setting untouched?

That is exactly what NFS does - it sets the keep-alive settings just for the
TCP connection that NFS uses.
The problem is that TCP keep-alives don't quite work as required.


>=20
> > However TCP does not send keepalives when the are packets in the queue
> > waiting to go out (which is appropriate) and also doesn't check for tim=
eouts
> > problem when the queue is full.
> >
> So if I understand correctly, the keepalives are sent when the=20
> connection is completely idle, but if the connection break happened=20
> during a transfer (queue not empty) then NFS would never find out as it=20
> wouldn't send anymore keepalives?

Exactly.

NeilBrown


--Sig_/kzNqN5BgbjG9rW9iv_Do4kx
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCnQVznsnt1WYoG5AQKBRRAAibFJ04rd+rIF31qcb23cUkp4RMrmL0pq
tN65LEt+1AkgSRbSY7cTzrDToGzMxYPQTKutbx3nySPMlbxDIrQeaef7dnEIyEz1
NJ4no3CRoGzi8hKVQK2IlL9ktLH+3N4luUW9QIUUgcjA35b2UFjfTM7i8+JTK0K8
wecn0e4rK6NP0cCWQTzJOiREtS7ZjWgDJMdS7MjJC/Jw7ly+tnLyLCoJEISq/7bG
Ie27MBNccRAXowcEW3lNSYfWRwaTxg/UPutI7IO8VTD0okqu25mjmKiFGXZ9I9rT
Nz05edCau+pZwNEwuUSFGRhHjvR2BYSj+8ctsBq6WfvdJSBYJBmPEsHt2qTGr9FT
9a9o/OPhahLtdL+DUpX2b8D9iFpB/DOt1AW4Q3ki0M10Q32TKHGZXZ/PlTrHX4X6
MOaohRif48UTW0XebuLZngIQsxmaAkf0eHM7MA8bvYOKL5hWGXtnHWx/OEcBLsii
nh6eKFPRgM1zLhVDtElFECaLckOmm8FJmeBvlp0Ub/pWD9wMFUjsbqinCbs23ITx
s0QxEfI36wSWLh/Vz6WJRBL+rVM1R96H4CeLndIzEtM9GQrnwHcatbr/bdtFGdB8
JT14Qw/F9yS9wZ6nCFbe1Bo11fssuZa4wV1KB4igoRoNgEPDprYnq5/2Fbw+72BU
QHE7aMs+uIU=
=iH9g
-----END PGP SIGNATURE-----

--Sig_/kzNqN5BgbjG9rW9iv_Do4kx--
