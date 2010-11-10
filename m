From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH 0/9] treewide: convert vprintk uses to %pV
Date: Wed, 10 Nov 2010 14:48:02 -0800
Message-ID: <AANLkTinhcbdm8YQOrFVdONODo6K6PcxHYtx5vqnap_3T@mail.gmail.com>
References: <cover.1289348757.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	cluster-devel@redhat.com, linux-nilfs@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42720 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757218Ab0KJWsZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 17:48:25 -0500
In-Reply-To: <cover.1289348757.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 9, 2010 at 4:35 PM, Joe Perches <joe@perches.com> wrote:
> Multiple secessive calls to printk can be interleaved.
> Avoid this possible interleaving by using %pV
>
> Joe Perches (9):
> =C2=A0drivers/gpu/drm/drm_stub.c: Use printf extension %pV
> =C2=A0drivers/isdn/mISDN: Use printf extension %pV
> =C2=A0drivers/net/wireless/ath/debug.c: Use printf extension %pV
> =C2=A0drivers/net/wireless/b43/main.c: Use printf extension %pV
> =C2=A0drivers/net/wireless/b43legacy/main.c: Use printf extension %pV
> =C2=A0fs/gfs2/glock.c: Use printf extension %pV
> =C2=A0fs/nilfs2/super.c: Use printf extension %pV
> =C2=A0fs/quota/dquot.c: Use printf extension %pV
> =C2=A0net/sunrpc/svc.c: Use printf extension %pV
>
> =C2=A0drivers/gpu/drm/drm_stub.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 14 +++++++--
> =C2=A0drivers/isdn/mISDN/layer1.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
| =C2=A0 10 +++++--
> =C2=A0drivers/isdn/mISDN/layer2.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
| =C2=A0 12 ++++++--
> =C2=A0drivers/isdn/mISDN/tei.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| =C2=A0 23 +++++++++++----
> =C2=A0drivers/net/wireless/ath/debug.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A09 +++++-
> =C2=A0drivers/net/wireless/b43/main.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 4=
8 ++++++++++++++++++++++++--------
> =C2=A0drivers/net/wireless/b43legacy/main.c | =C2=A0 47 +++++++++++++=
+++++++++++--------
> =C2=A0fs/gfs2/glock.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A09 +++++-
> =C2=A0fs/nilfs2/super.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 23 +++++++++++-----
> =C2=A0fs/quota/dquot.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 12 +++++---
> =C2=A0net/sunrpc/svc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 12 +++++---
> =C2=A011 files changed, 161 insertions(+), 58 deletions(-)

When was this added upstream BTW? I ask for backport considerations.

  Luis
