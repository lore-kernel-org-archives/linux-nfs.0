Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:39356 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664Ab3IQCVA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Sep 2013 22:21:00 -0400
Date: Mon, 16 Sep 2013 21:20:51 -0500
From: Contact <contact@ryper.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 16+ GID issue, mountd's --manage-gids not helping
Message-ID: <20130916212051.12b0fafe@svelte.ryper.org>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9467CD9A6@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130916094351.263d433d@svelte.ryper.org>
	<20130916193709.GA25308@fieldses.org>
	<20130916175612.012d7301@svelte.ryper.org>
	<20130916232024.GC25308@fieldses.org>
	<20130917003825.GD25308@fieldses.org>
	<20130916201105.717449b1@svelte.ryper.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9467CD9A6@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

THAT DID IT!

You guys are awesome! I didn't realize that they had to be the same for
the user. I thought that was independent of the user on the server's
end. So user 1000 has to have GID 1100 on both client and server. I
will remember that.

Again, thank you so much. I apologize if I made this more difficult
than it needed to be.


On Tue, 17 Sep 2013 01:59:42 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of Contact
> > Sent: Monday, September 16, 2013 9:11 PM
> > To: J. Bruce Fields
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: 16+ GID issue, mountd's --manage-gids not helping
> > 
> > Hello,
> > 
> > My apologies for not providing the information that you requested.
> > 
> > (client)
> > rypervenche@svelte ~ $ id
> > uid=1000(rypervenche) gid=1000(rypervenche)
> > groups=1000(rypervenche),4(adm),6(disk),7(lp),10(wheel),16(cron),18(audio
> > ),27(video),35(games),70(postgres),85(usb),100(users),103(vboxusers),105(
> > wireshark),106(lpadmin),244(plugdev),246(crontab),250(portage),1100(nfs)
> > 
> > (server)
> > nfs@noir ~ $ id
> > uid=1100(nfs) gid=1100(nfs) groups=1100(nfs)
> 
> Does the '/etc/groups' entries for the user with uid=1000 on the
> server match those listed above for the client?
> 
> --manage-gids will only work correctly if the /etc/passwd
> and /etc/groups entries on the server match those on the client.
> 
> Cheers,
>   Trond

