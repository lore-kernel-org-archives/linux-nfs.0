From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: pNFS timeouts
Date: Mon, 14 Jun 2010 17:12:31 +0200
Message-ID: <20100614151231.GF17703@ics.muni.cz>
References: <20100614085157.GS17703@ics.muni.cz>
 <4C163892.20201@panasas.com>
 <20100614142332.GB17703@ics.muni.cz>
 <4C1640DF.5070506@panasas.com>
 <4C164490.6010903@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:55259 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495Ab0FNPMe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 11:12:34 -0400
In-Reply-To: <4C164490.6010903@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 14, 2010 at 11:02:40AM -0400, Benny Halevy wrote:
> looking at http://charon.styxx.cz/tmp/pnfs/pnfs_write_log.txt
> There seem to 15 seconds form after getting an NFS4ERR_DELAY
> from a DS write to the respective commit.

this debug is not applicable to DS?

echo 32767 > /proc/sys/sunrpc/nfs_debug

I can provide debug output from DS, but this does not seem to produce a=
ny
debug output.

--=20
Luk=E1=B9 Hejtm=E1nek
