Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39696 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759954Ab2BJTN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 14:13:56 -0500
Date: Fri, 10 Feb 2012 14:13:54 -0500
To: steve <steve@steve-ss.com>
Cc: Daniel Kahn Gillmor <dkg@fifthhorseman.net>, whats_up@gmx.net,
        linux-nfs@vger.kernel.org
Subject: Re: mount hangs in NFS4+Kerberos setup
Message-ID: <20120210191354.GC5781@fieldses.org>
References: <20120210154526.7b504146@little-poseidon>
 <4F35512A.9050500@steve-ss.com>
 <20120210184154.03fb6907@little-poseidon>
 <4F355CD2.6040603@steve-ss.com>
 <4F35603A.5050508@fifthhorseman.net>
 <4F356AB7.7070408@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F356AB7.7070408@steve-ss.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 10, 2012 at 08:06:31PM +0100, steve wrote:
> On 02/10/2012 07:21 PM, Daniel Kahn Gillmor wrote:
> >On 02/10/2012 01:07 PM, steve wrote:
> >>Officially, you should not export from a pseudo root. Please see the
> >>last few lines in the link I sent.
> >That link offers the same assertion but no explanation for it.  Can you
> >explain why that's the recommendation?
> Sorry, no. I can however explain why we changed: We were having
> problems with idmapd uid:gid mappings from the bind mount and just
> as an experiment we tried the old way. Problem solved.

That almost had to be a coincidence--there's no connection between the
two things.

--b.

> >If an admin were to remove fsid=0 from their exports line, they'd also
> >need to adjust the paths in all the connecting clients, right?
> >
> >	--dkg
> No. If you are exporting /export fsid-0 and crossmnt-ing
> /export/opt, you mount server:/opt client/somewhere. The only file
> you change is /etc/exports on the server, to contain the old style
> mount spec.
> /opt yourIPs(rw,sec=none:sys:krb5. . .)
> The client sees exactly he same path.
> 
> HTH
> Steve
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
