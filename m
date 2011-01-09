Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from somacoma.net ([62.75.137.225]:36270 "EHLO vs137225.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab1AILac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Jan 2011 06:30:32 -0500
Subject: Re: Problem with sharing /home
From: Daniel Stodden <daniel.stodden@citrix.com>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <502676.48699.qm@web111713.mail.gq1.yahoo.com>
References: <965737.12090.qm@web111718.mail.gq1.yahoo.com>
	 <1294565607.30270.14.camel@ramone>
	 <502676.48699.qm@web111713.mail.gq1.yahoo.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 09 Jan 2011 03:30:28 -0800
Message-ID: <1294572628.30270.23.camel@ramone>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2011-01-09 at 04:43 -0500, Mahmood Naderan wrote:
> >Make sure that the name->uid map is identical in all passwd files.
> > Try the 'id' and 'ls -n' commands to figure it out. Edit passwd andgroup to fix 
> >it.
> 
> Can you explain more? "id" shows the UID for each user and "ls -n" shows which 
> UID grant the /home/direcotry.  Which sections of passwd and group have to be 
> changed?

$ man 5 passwd



