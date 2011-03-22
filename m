Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.conversis.de ([213.203.219.181]:41985 "EHLO
	mail4.conversis.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab1CVRnc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 13:43:32 -0400
Message-ID: <4D88DFC1.10400@conversis.de>
Date: Tue, 22 Mar 2011 18:43:29 +0100
From: Dennis Jacobfeuerborn <dennisml@conversis.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: bind mounts, crossmnt and multi client nfsv3
References: <4D86B6F2.1070004@conversis.de> <20110321140923.5a618d89@notabene.brown> <4D874419.5030303@conversis.de> <20110321172530.GA32359@fieldses.org> <4D87908E.1020107@conversis.de> <20110321181913.GA472@fieldses.org> <4D87A135.6090309@conversis.de>
In-Reply-To: <4D87A135.6090309@conversis.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/21/2011 08:04 PM, Dennis Jacobfeuerborn wrote:

[SNIP]

> I'd be interested to move on to v4 but from what I've heard the
> user-mapping no longer is done using the uid. Since the users don't have
> entries in /etc/passwd and exist purely as id's in the filesystem the
> username based mapping in nfsv4 doesn't allow me to use it in this case.
> I guess the only way to accomplish that would be to write a custom
> rpcidmapd daemon?
>
> I'm currently downloading the openfiler installer so I can replicate the
> setup here for better testing. Maybe updating the nfs-utils package to a
> more current version will have an impact.

Apparently I need to export both the /exports directory and all the letter 
directories beneath it for the crossmnt option to work, e.g.:

/exports 192.168...
/exports/country/de/a 192.168...
/exports/country/de/b 192.168...
/exports/country/de/c 192.168...
etc.

Regards,
   Dennis
