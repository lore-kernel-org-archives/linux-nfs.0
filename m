Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34595 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806Ab1ITNaS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 09:30:18 -0400
Date: Tue, 20 Sep 2011 09:30:16 -0400
To: Jan-Marek Glogowski <glogow@fbihome.de>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: Problem useing groups containing spaces in NFSv4
Message-ID: <20110920133016.GF1800@fieldses.org>
References: <alpine.DEB.2.02.1108262018320.28308@users.fbihome.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.02.1108262018320.28308@users.fbihome.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 26, 2011 at 10:58:15PM +0200, Jan-Marek Glogowski wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Hi
> 
> I'm on Debian Squeeze using NFSv4 (2.6.32 / 1.1.2). Groups ares
> stored in LDAP and one contains a space. If I want to chgrp a file,
> the chown system call gets stuck and I get an kernel "hung_task"
> backtrace:
> 
> [76920.364077] INFO: task chown:31709 blocked for more than 120 seconds.
> [76920.364781] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [76920.365894] chown         D 0000000000000000     0 31709  28415 0x00000004
> [76920.365900]  ffffffff814611f0 0000000000000086 0000000000000000 ffff88000886de88
> [76920.365906]  ffff88000886dde8 ffffffff810f6211 000000000000f9e0 ffff88000886dfd8
> [76920.365910]  0000000000015780 0000000000015780 ffff88003ed269f0 ffff88003ed26ce8
> [76920.365914] Call Trace:
> [76920.365927]  [<ffffffff810f6211>] ? path_to_nameidata+0x15/0x37
> [76920.365933]  [<ffffffff811035cd>] ? mntput_no_expire+0x23/0xee
> [76920.365940]  [<ffffffff812fb99b>] ? __mutex_lock_common+0x122/0x192
> [76920.365945]  [<ffffffff810f9c1c>] ? user_path_at+0x52/0x79
> [76920.365948]  [<ffffffff812fbac3>] ? mutex_lock+0x1a/0x31
> [76920.365954]  [<ffffffff810ed746>] ? chown_common+0x5b/0x7c
> [76920.365958]  [<ffffffff812fe9f6>] ? do_page_fault+0x2e0/0x2fc
> [76920.365962]  [<ffffffff810ed982>] ? sys_fchownat+0x53/0x70
> [76920.365967]  [<ffffffff81010b42>] ? system_call_fastpath+0x16/0x1b
> [77240.440046] nfs: server buildserv-next not responding, still trying
> [95664.836086] nfs: server buildserv-next not responding, still trying
> [96568.599435] nfs: server buildserv-next OK
> 
> So I backported the Debian nfs-utils 1.1.4 and updated the kernel to
> the squeeze-backports version (2.6.39).
> 
> The backtrace is now gone, but the chgrp process is still stuck.
> 
> The client rpc.idmapd seems to be fine:
> 
> Aug 26 20:41:41 kvm-auth rpc.idmapd[973]: nfs4_gid_to_name: calling nsswitch->gid_to_name
> Aug 26 20:41:41 kvm-auth rpc.idmapd[973]: nfs4_gid_to_name: nsswitch->gid_to_name returned 0
> Aug 26 20:41:41 kvm-auth rpc.idmapd[973]: nfs4_gid_to_name: final return value is 0
> Aug 26 20:41:41 kvm-auth rpc.idmapd[973]: Client 0: (group) id "1094" -> name "Domain Administrators@tvc.muenchen.de"
> 
> On the server side I see idmapd errors in the daemon.log (every 2
> minutes, so I guess the backtrace is just suppressed - same as the
> previous 120 sec timeout):
> 
> Aug 26 20:27:48 buildserv-next rpc.idmapd[16848]: nfsdcb: authbuf=* authtype=group
> Aug 26 20:27:48 buildserv-next rpc.idmapd[16848]: nfsdcb: bad name in upcall
> 
> There is an invalid check in the idmapd code, which converts the
> octal encoded values back to the original characters (see attached
> patch).

The patch makes sense to me, thanks; steved, could you apply?

> What I don't know is how to implement the "real" error handling. I
> don't think the client process should be stuck forever, just because
> the server fails to find the encoded name.

Agreed that if a name couldn't be mapped, we do still want to respond to
the kernel to tell it that, so that it can handle the problem and
continue.  I think we do that correctly.

I think this case is a little different--if we have a failure here in
the decoding, it means that there's a bug somewhere, either in the
kernel's encoding or our parsing.  In that case there's no real recourse
other than logging an error and hoping a helpful user tells us about it!

--b.

> 
> Regards,
> 
> Jan-Marek Glogowski
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.10 (GNU/Linux)
> 
> iEYEARECAAYFAk5YCOcACgkQj6MK58wZA3dMkwCghsoYANdq8FZNYCP/C8X5UH+w
> hTEAnRN59WxzjHZ1dcDXIxu9G4hdFEOn
> =cYDx
> -----END PGP SIGNATURE-----

> idmapd: correctly convert octal encoded field values
> 
> We want to check for (unsigned char) -1.
> 
> --- nfs-utils-1.2.4.orig/utils/idmapd/idmapd.c
> +++ nfs-utils-1.2.4/utils/idmapd/idmapd.c
> @@ -925,9 +925,9 @@ getfield(char **bpp, char *fld, size_t f
>  		if (*bp == '\\') {
>  			if ((n = sscanf(bp, "\\%03o", &val)) != 1)
>  				return (-1);
> -			if (val > (char)-1)
> +			if (val > UCHAR_MAX)
>  				return (-1);
> -			*fld++ = (char)val;
> +			*fld++ = val;
>  			bp += 4;
>  		} else {
>  			*fld++ = *bp;

