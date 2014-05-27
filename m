Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44433 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751830AbaE0UyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2014 16:54:09 -0400
Date: Tue, 27 May 2014 16:54:07 -0400
To: Jaap <jwinius@umrk.nl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 with Kerberos and no_root_squash
Message-ID: <20140527205407.GB32160@fieldses.org>
References: <llqgta$3d3$1@ger.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <llqgta$3d3$1@ger.gmane.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 24, 2014 at 04:20:58PM +0000, Jaap wrote:
> Hi folks,
> 
> Not long ago I managed to get NFSv4 to work together with Kerberos (gss/
> krb5i or gss/krb5p), but apparently there's a limitation. It has to do 
> with exports that include the "no_root_squash" option and then attempting 
> to allow root on the clients to write to them; this always results in a 
> "Permission denied" error.
> 
> Is there a solution for this, or a workaround?
> 
> For me this is important, because one of the sites I maintain uses NFS 
> for home directories and the workstations have an elaborate logout script 
> in /etc/X11/Xreset.d/ that runs as root (the script contains many sudo 
> commands to make changes to the user's home directories). Therefore, one 
> solution would be to avoid running the logout script as root, but AFAIK 
> that's not possible.

You may want to look at "Credentials for UID 0" in the rpc.gssd man
page?

--b.
