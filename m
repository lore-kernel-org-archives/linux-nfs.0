Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60452 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912Ab2LDPyI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 10:54:08 -0500
Date: Tue, 4 Dec 2012 10:54:07 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: server support for multiple tcp fragments
Message-ID: <20121204155407.GD18674@fieldses.org>
References: <1354625926-18527-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1354625926-18527-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 04, 2012 at 07:58:41AM -0500, J. Bruce Fields wrote:
> I wanted to use pynfs to reproduce a bug with the server's handling of
> certain large compounds, but ran into trouble because pynfs likes to
> break up rpc's into 2k fragments.  Rather than fixing pynfs I decided
> it's long past time we should have fixed this bug in the server....
> 
> I'm planning to queue this up for 3.8.--b.

To help test I also added a test that does a maximum-size write to:

	git://linux-nfs.org/~bfields/pynfs.git master

--b.
