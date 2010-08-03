Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:34113 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757820Ab0HCV5G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 17:57:06 -0400
Date: Tue, 3 Aug 2010 17:57:04 -0400
From: Jim Rees <rees@umich.edu>
To: Daniel.Muntz@emc.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100803215704.GA15494@merit.edu>
References: <201008030401.33552.dreck@vmsd.ath.cx>
 <20100803164318.GB13896@merit.edu>
 <20100803192216.GC31579@fieldses.org>
 <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Daniel.Muntz@emc.com wrote:

  I'll fourth this motion.  The spec goes out of its way to declare this a
  violation.  IMHO, the NFSv4.[0-n] specs should adopt the convention that a
  uid string consisting of [0-9]+ be interpreted as the string
  representation of a numeric UID--just as valid as a "user@domain" string.

I argued for this as an option in the early days but was shouted down.
Sorry I can't remember the details, it was many years ago.
