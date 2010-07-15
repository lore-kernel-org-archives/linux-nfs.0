Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:54103 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934057Ab0GOSc0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 14:32:26 -0400
Date: Thu, 15 Jul 2010 14:24:03 -0400
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Marc Eshel <eshel@almaden.ibm.com>, linux-nfs@vger.kernel.org
Subject: Re: Linux pNFS status meeting 07/15
Message-ID: <20100715182402.GA2889@merit.edu>
References: <OF01D34025.9BF2DCCC-ON88257760.007510C5-88257760.007530DA@us.ibm.com>
 <20100714212928.GD8161@fieldses.org>
 <20100715172836.GC15126@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100715172836.GC15126@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:

  Jim Rees:
  	- bugfixing complex-volume patches; not ready to submit to Benny
  	  quite yet.

Actually that's not quite what I intended to say.  The patches are ready to
go and have passed cthon tests against both EMC and spnfs servers.  I would
have sent them already but I'm conservative and rebasing to the
pnfs-all-latest branch, which changed yesterday.  Look for the patches
within the next hour or two.
