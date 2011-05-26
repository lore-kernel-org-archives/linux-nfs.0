From: Upakul Barkakaty <upakul@gmail.com>
Subject: IPv6 support for NFSv2 server.
Date: Thu, 26 May 2011 23:57:04 +0530
Message-ID: <BANLkTi=s4_A-WiG_a11pLgmeQ39qw=22Hg@mail.gmail.com>
References: <7C481A0A0BBE9E4BA110F26D7A2BFFDC026E7C46@nodmx01.igglobal.com>
	<BANLkTikzuTGgHU=oUMTjmPhfsR_-nD5Ffw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62534 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780Ab1EZS1E convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 14:27:04 -0400
Received: by iyb14 with SMTP id 14so821330iyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 May 2011 11:27:04 -0700 (PDT)
In-Reply-To: <BANLkTikzuTGgHU=oUMTjmPhfsR_-nD5Ffw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I have been contemplating about using an appropriate server that would
support NFSv2 over IPv6.

RHEL5 doesn=92t support IPv6 over NFS by default. I tried installing a
few libraries and patches but it doesn=92t seem to be working out yet
due to some missing dependencies.

RHEL6 *seems* to support just the NFS client over IPv6. Further it
seems to support only NFSv4 as it generates an error if I force the
NFS version to 2 in the mount options[mount.nfs: an incorrect mount
option was specified].

=46rom the RHEL6.1 Technical documentation, it specifies that NFS serve=
r
support over IPv6 is introduced in this release. However it is still
not clear if the support is still over NFSv4 only or includes NFSv2 as
well.

Is there any standard Operating system distribution that currently
supports NFSv2 server over IPv6? Any inputs will be greatly
appreciated.

Thanks and Best Regards,
Upakul Barkakaty
