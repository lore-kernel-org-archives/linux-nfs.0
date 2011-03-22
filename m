Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45830 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774Ab1CVRyK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2011 13:54:10 -0400
Date: Tue, 22 Mar 2011 13:54:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dennis Jacobfeuerborn <dennisml@conversis.de>
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: bind mounts, crossmnt and multi client nfsv3
Message-ID: <20110322175406.GC14627@fieldses.org>
References: <4D86B6F2.1070004@conversis.de>
 <20110321140923.5a618d89@notabene.brown>
 <4D874419.5030303@conversis.de>
 <20110321172530.GA32359@fieldses.org>
 <4D87908E.1020107@conversis.de>
 <20110321181913.GA472@fieldses.org>
 <4D87A135.6090309@conversis.de>
 <4D88DFC1.10400@conversis.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D88DFC1.10400@conversis.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 22, 2011 at 06:43:29PM +0100, Dennis Jacobfeuerborn wrote:
> On 03/21/2011 08:04 PM, Dennis Jacobfeuerborn wrote:
> 
> [SNIP]
> 
> >I'd be interested to move on to v4 but from what I've heard the
> >user-mapping no longer is done using the uid. Since the users don't have
> >entries in /etc/passwd and exist purely as id's in the filesystem the
> >username based mapping in nfsv4 doesn't allow me to use it in this case.
> >I guess the only way to accomplish that would be to write a custom
> >rpcidmapd daemon?
> >
> >I'm currently downloading the openfiler installer so I can replicate the
> >setup here for better testing. Maybe updating the nfs-utils package to a
> >more current version will have an impact.
> 
> Apparently I need to export both the /exports directory and all the
> letter directories beneath it for the crossmnt option to work, e.g.:
> 
> /exports 192.168...
> /exports/country/de/a 192.168...
> /exports/country/de/b 192.168...
> /exports/country/de/c 192.168...

Huh.  I did just a quick test, mount --bind'ing a couple directories
under a crossmnt export, and verified that I could see the result from
an nfsv3 client.

2.6.38-ish kernel, fc13 userspace (nfs-utils-1.2.2-6).

--b.
