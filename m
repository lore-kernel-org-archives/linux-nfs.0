From: Paul Jakma <paulj@alphyra.ie>
Subject: Re: [PATCH] Secure user authentication for NFS using RPCSEC_GSS
 [0/6]
Date: Mon, 13 Jan 2003 07:49:12 +0000 (GMT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0301130745510.26185-100000@dunlop.admin.ie.alphyra.com>
References: <1042437391.1677.8.camel@thud>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Dax Kelson <Dax.Kelson@gurulabs.com>
In-Reply-To: <1042437391.1677.8.camel@thud>
List-ID: <nfs.lists.sourceforge.net>

On 12 Jan 2003, Dax Kelson wrote:

> Standard NFS security/authentication sucks rocks. Without this NFS home
> directory servers are just waiting to be ransacked by a rouge (or
> compromised) root user on a client machine.

AIUI, A root user still can. The users krbv5 credentials will
generally have been cached to storage. (though i suppose one could
mount that storage via NFS and use root_squash, but that's little 
protection.).

> NFSv4 w/RPSEC_GSS is finally a native UNIX filesharing solution that
> I don't have to be ashamed of when hanging with admins of those
> "other OSes".

Unless NFSv4 has dealt with the problem above, it isnt much protection 
from rogue root users.

> Dax

regards,
-- 
Paul Jakma	Sys Admin	Alphyra
	paulj@alphyra.ie
Warning: /never/ send email to spam@dishone.st or trap@dishone.st
