Return-Path: linux-nfs-owner@vger.kernel.org
Received: from master.debian.org ([70.103.162.29]:40528 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756009Ab1LESm1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 13:42:27 -0500
Date: Mon, 5 Dec 2011 18:42:06 +0000
From: Anibal Monsalve Salazar <anibal@debian.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org,
        Michael Rasmussen <mir@datanom.net>, 651032@bugs.debian.org,
        Rares Aioanei <schaiba@gmail.com>, 649491@bugs.debian.org,
        Bjoern Buerger <bbu@pengutronix.de>, 650904@bugs.debian.org,
        steven@nchc.org.tw, 650948@bugs.debian.org
Subject: Re: Bug#651032: /usr/sbin/rpc.idmapd: rpc.idmapd referring to none
 existing library
Message-ID: <20111205184206.GA5207@debian.org>
References: <20111205071808.5626.67399.reportbug@sleipner.datanom.net>
 <20111205082520.GA5890@debian.org>
 <4EDCE8B2.1050702@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EDCE8B2.1050702@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 05, 2011 at 10:52:18AM -0500, Steve Dickson wrote:
>Why not just use the --with-pluginpath configuration flag?
>That's how we do it in Fedora...

The --with-pluginpath configuration option isn't in 0.24.

I run

 ./configure --help

and it doesn't list the --with-pluginpath configuration option.

The configure commands doesn't unrecognize the --with-pluginpath option.
See below.

 CFLAGS="-Wall -g -O2" ./configure --host=i486-linux-gnu \
 --build=i486-linux-gnu --prefix=/usr --mandir=\${prefix}/share/man \
 --infodir=\${prefix}/share/info --with-pluginpath=/lib/libnfsidmap
 configure: WARNING: unrecognized options: --with-pluginpath

The git repo has patches to add the --with-pluginpath configuration
option. Do you plan to release libnfsidmap 0.25 soon?
