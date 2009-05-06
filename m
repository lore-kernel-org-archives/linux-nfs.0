From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: very slow NFS boot on linux-next and -mm
Date: Wed, 6 May 2009 15:42:58 +0200
Message-ID: <ac3eb2510905060642o41f9c68rf1138e94d76d611c@mail.gmail.com>
References: <20090503105456.GA30449@localhost> <20090503124013.GA31700@localhost>
	<ac3eb2510905030556p4ce25ff1w9aa5cbf76be2e206@mail.gmail.com>
	<20090504133019.GA14300@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20090504133019.GA14300@localhost>
Sender: linux-hotplug-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 4, 2009 at 15:30, Wu Fengguang <fengguang.wu@intel.com> wro=
te:

> I tried remove every udev rules in /etc/udev/ and /lib/udev, the /etc=
/group
> accesses disappeared in strace, but udevd is still busy.

> ppoll([{fd=3D4, events=3DPOLLIN}, {fd=3D5, events=3DPOLLIN}, {fd=3D3,=
 events=3DPOLLIN}], 3, NULL, [], 8) =3D 1 ([{fd=3D3, revents=3DPOLLIN}]=
)
> ioctl(3, FIONREAD, [39]) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0=3D 0
> read(3, 0x62ad60, 39) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D -1 EINVAL (Invalid argument)

Seems, you have issues with inotify on your nfs mount?

Inotify wakes up udevd to tell something in the rules directory has
changed, but inotify seems not to return anything useful, but keeps
waking us up. That causes an endless loop of parsing rules files.

Thanks,
Kay
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
