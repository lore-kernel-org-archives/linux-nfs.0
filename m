Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0234.hostedemail.com ([216.40.44.234]:37749 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753581AbbCaAPA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 20:15:00 -0400
Message-ID: <1427760888.14276.37.camel@perches.com>
Subject: Re: [PATCH 00/25] treewide: Use bool function return values of
 true/false not 1/0
From: Joe Perches <joe@perches.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org,
        linux-omap@vger.kernel.org, kvm-ppc@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-ide@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net,
        linux-mm@kvack.org, linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        alsa-devel@alsa-project.org, bridge@lists.linux-foundation.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        patches@opensource.wolfsonmicro.com, linux-hexagon@vger.kernel.org,
        linux-ia64@vger.kernel.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-security-module@vger.kernel.org
Date: Mon, 30 Mar 2015 17:14:48 -0700
In-Reply-To: <5519E53B.5040504@schaufler-ca.com>
References: <cover.1427759009.git.joe@perches.com>
	 <5519E53B.5040504@schaufler-ca.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2015-03-30 at 17:07 -0700, Casey Schaufler wrote:
> On 3/30/2015 4:45 PM, Joe Perches wrote:
> > Joe Perches (25):
> >   arm: Use bool function return values of true/false not 1/0

[etc...]

> Why, and why these in particular?

bool functions are probably better returning
bool values instead of 1 and 0.

Especially when the functions intermix returning
returning 1/0 and true/false.

(there are only a couple of those though)

These are all the remaining instances in the
kernel tree.

