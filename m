Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44728 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037Ab1ADSho convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 13:37:44 -0500
Received: by bwz15 with SMTP id 15so14819122bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 04 Jan 2011 10:37:43 -0800 (PST)
In-Reply-To: <4D23589B.6030409@cora.nwra.com>
References: <4D23589B.6030409@cora.nwra.com>
Date: Tue, 4 Jan 2011 13:37:41 -0500
Message-ID: <AANLkTik3XOGSX_X4mRYWP4XA-j8t1DSn7JVrY6gZLaak@mail.gmail.com>
Subject: Re: Trouble mounting from EL5.5 server on Fedora 14 -
 gss_kerberos_mech: unsupported algorithm 6
From: Kevin Coffman <kwc@citi.umich.edu>
To: Orion Poplawski <orion@cora.nwra.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 4, 2011 at 12:27 PM, Orion Poplawski <orion@cora.nwra.com> wrote:
> I'm trying to get kerberized NFSv4 setup for the first time (have had
> non-secure v4 up for a while).  Client is Fedora 14, server is CentOS 5.5.
>
> [ ... ]
>
> keytabs on server and client are like:
>
>   3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (Triple DES cbc mode with
> HMAC/sha1)
>   3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (ArcFour with HMAC/md5)
>   3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (DES with HMAC/sha1)
>   3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (DES cbc mode with RSA-MD5)
>
> Any ideas?

Only DES is supported for your server's kernel:

http://www.citi.umich.edu/projects/nfsv4/linux/krb5-setup.html
