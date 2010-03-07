From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems with crossmnt since 1.2.1
Date: Sun, 7 Mar 2010 15:06:07 -0500
Message-ID: <20100307200607.GA13006@fieldses.org>
References: <20100228100643.GG26178@teal.hq.k1024.org> <20100301204010.GE23539@fieldses.org> <20100301211306.GA16341@teal.hq.k1024.org> <20100302032002.GA29212@fieldses.org> <20100307195449.GE9237@teal.hq.k1024.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33301 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754773Ab0CGUEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Mar 2010 15:04:47 -0500
In-Reply-To: <20100307195449.GE9237-kWFYwFCQMdQkLqoNrXjPMti2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 07, 2010 at 08:54:49PM +0100, Iustin Pop wrote:
> Sorry for the delayed response. I can confirm this solves my test case. I get
> the right mount options in both the "mount directly the sub-directory" case,
> and in the "mount parent and access the sub-directory via the crossmnt feature"

Excellent, thanks.  Steve, could you apply the following patches?

Also available from

	git pull git://linux-nfs.org/~bfields/nfs-utils.git crossmnt-fixes

--b.
