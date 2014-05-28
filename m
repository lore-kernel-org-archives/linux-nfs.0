Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45130 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310AbaE1OFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2014 10:05:46 -0400
Date: Wed, 28 May 2014 10:05:44 -0400
To: Jaap <jwinius@umrk.nl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 with Kerberos and no_root_squash
Message-ID: <20140528140544.GB22210@fieldses.org>
References: <llqgta$3d3$1@ger.gmane.org>
 <20140527205407.GB32160@fieldses.org>
 <lm36lj$bbb$1@ger.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <lm36lj$bbb$1@ger.gmane.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 27, 2014 at 11:21:24PM +0000, Jaap wrote:
> On Tue, 27 May 2014 16:54:07 -0400, J. Bruce Fields wrote:
> 
> > You may want to look at "Credentials for UID 0" in the rpc.gssd man
> > page?
> 
> If you mean that I should run rpc.gssd with the "-n" option, in that case 
> I still get "Permission denied" when attempting to write to one of the 
> "no_root_squash" exports as root.

What credentials is root using in that case?

> I even tried using the machine 
> credentials "root/<hostname>@<REALM>" instead of "host/..." , but to no 
> avail.

Right, I'd expect that to be mapped to nobody.

You can set up a one-off mapping for a given machine credential in
idmapd.conf.  (If you're using rpc.svcgssd.  If you're using gss-proxy I
think there's similar configuration in /etc/krb5.conf.)

--b.
