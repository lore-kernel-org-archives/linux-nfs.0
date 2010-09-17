From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: how to limit disk IO utilization by the nfs server?
Date: Fri, 17 Sep 2010 13:28:06 -0400
Message-ID: <20100917172806.GB25515@fieldses.org>
References: <4C9289B5.8050002@limepepper.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom <tom-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57788 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754074Ab0IQR3V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Sep 2010 13:29:21 -0400
In-Reply-To: <4C9289B5.8050002-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 16, 2010 at 10:18:45PM +0100, Tom wrote:
> I would like to throttle the nfs server's IO utilization as when its
> at 100% its causing problems, and I would like to restrict the
> clients.

What sort of problems, exactly?

Which kernel version are you using?

> Any suggestions on how I can do this?

I don't know how, unfortunately.

--b.
