Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38065 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756010Ab1CCG0V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 01:26:21 -0500
Date: Thu, 3 Mar 2011 01:26:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] Give svcgssd access to kernel's supported enctypes
Message-ID: <20110303062621.GG7724@fieldses.org>
References: <1299113502-17179-1-git-send-email-kwc@citi.umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1299113502-17179-1-git-send-email-kwc@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 02, 2011 at 07:51:40PM -0500, Kevin Coffman wrote:
> Make the kernel's supported enctypes available to user-land
> (svcgssd) via a new proc file.  The client side already gets
> this information in the upcall to gssd, we need to make it
> available to svcgssd.

They look good to me; I'll queue them up for 2.6.39 if nobody else sees
a problem.

Do you have the nfs-utils bits ready as well?

--b.
