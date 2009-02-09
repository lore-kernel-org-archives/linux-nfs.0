Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60244 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696AbZBIUrV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 15:47:21 -0500
Date: Mon, 9 Feb 2009 15:47:26 -0500
To: Greg Banks <gnb@melbourne.sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
Subject: Re: [patch 0/3] First tranche of SGI Enhanced NFS patches
Message-ID: <20090209204726.GH13636@fieldses.org>
References: <20090113102633.719563000@sgi.com> <498FBE0B.1040104@melbourne.sgi.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <498FBE0B.1040104@melbourne.sgi.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 09, 2009 at 04:24:27PM +1100, Greg Banks wrote:
> Bruce, any word on these?  I don't seem to have any specific review
> items that I need to pay attention to with these patches, and I don't
> see them in your for-2.6.30 branch, so can I get an ack or a nack or
> feedback on things that need fixing?

Sorry, that came around the time of the citi compromise, so I just
registered that it had gotten some responses, figured it'd probably be
resent, and filed it away....

(And, by the way, if anyone's waiting for me to respond to email from
the last month--you mght want to resend.  The longer version:

We now believe that password-logging ssh and sshd were installed on citi
machines as early as November.  We got reports of ssh scanning in
December and January, but just took down the misbehaving machines.  In
mid-January we finally realized the problem was serious, disconnected
ourselves from the internet completely, took everything on our local
network offline (including our main mail server and linux-nfs.org), then
brought our external connection back up and slowly reconnected machines
to our local network as we audited and/or rebuilt them as appropriate.

To be cautious, I also did the same for my personal machines (including
my personal mail server), though I didn't have specific evidence they'd
been compromised.

The upshot is: there were a few days when mail wasn't getting through at
all, and I know at least some was never delivered.  When it did get
through, I wasn't necessarily able to pay it much attention.  So besides
just a sob-story, this is a request that people ping me if I haven't
responded to something I should have lately.)

--b.
