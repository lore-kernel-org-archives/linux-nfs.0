Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.SerNet.de ([193.175.80.2]:41335 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754071Ab1FJIGf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jun 2011 04:06:35 -0400
Date: Fri, 10 Jun 2011 09:56:49 +0200
Date: Fri, 10 Jun 2011 09:56:49 +0200
From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        samba-technical@lists.samba.org, Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] locks: breaking read lease should not block read open
Reply-To: Volker.Lendecke@SerNet.DE
References: <20110609231606.GB22215@fieldses.org>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20110609231606.GB22215@fieldses.org>
Message-Id: <E1QUwaT-00HRZw-74@intern.SerNet.DE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 09, 2011 at 07:16:06PM -0400, J. Bruce Fields wrote:
> The lease code behavior during the lease-breaking process is strange.
> Fixing it completely would be complicated by the fact that the current
> code allows a lease break to downgrade the lease instead of necessarily
> removing it.
> 
> But I can't see what the point of that feature is.  And googling around
> and looking at the Samba code, I can't see any evidence that anyone uses
> it.  Think we could just do away with removing the ability to downgrade
> to satisfy a lease break?

Without having looked too deeply, just let me point out that
Samba here has a plain flaw. Early Linux Kernel versions
that we programmed against did not properly support read
only leases, so we did not implement that initially. If I
remember correctly we never got around to finally do it once
it became available. Eventually we will probably, as read
only leases are a pretty important feature to present to
CIFS clients.

Volker

-- 
SerNet GmbH, Bahnhofsallee 1b, 37081 Göttingen
phone: +49-551-370000-0, fax: +49-551-370000-9
AG Göttingen, HRB 2816, GF: Dr. Johannes Loxen
