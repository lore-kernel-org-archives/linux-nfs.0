Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:36581 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751384Ab2BJRl5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2012 12:41:57 -0500
Date: Fri, 10 Feb 2012 18:41:54 +0100
From: <whats_up@gmx.net>
To: steve <steve@steve-ss.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: mount hangs in NFS4+Kerberos setup
Message-ID: <20120210184154.03fb6907@little-poseidon>
In-Reply-To: <4F35512A.9050500@steve-ss.com>
References: <20120210154526.7b504146@little-poseidon>
	<4F35512A.9050500@steve-ss.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> Some older kernels do not support strong keys. Try adding:
> allow_weak_crypto = true
> to the
>   [libdefaults]
> in /etc/krb5.conf

yes. I painfully (mount only says access denied) found out this already
and I use allow_weak_crypto to limit to DES. More encryption
types have been introduced with kernel 2.6.39...

I tried to use kernel 3.2 from squeeze-backports but this introduced new
errors, thus I decided to try with 2.6 first.


> Also it's not recommended to use the pseudo-root fsid=0 method for
> nfs exports under Linux:
>   http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration

hmm, as far as I have understood I have to:
- export the root folder /exports explicitly beside the "real"
  exports p.ex. /exports/opt
- use fsid=0 for the root folder to force version 4 of NFS

What's your suggestion to improve/secure my configuration?

regards
  knut
