Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:42108 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab1DDXFc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2011 19:05:32 -0400
Date: Mon, 4 Apr 2011 19:05:28 -0400
From: Jim Rees <rees@umich.edu>
To: Andrew Klaassen <clawsoon@yahoo.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Prioritizing readdirplus/getattr/lookup
Message-ID: <20110404230528.GA2624@merit.edu>
References: <13701.83906.qm@web65411.mail.ac4.yahoo.com>
 <882887.75491.qm@web65412.mail.ac4.yahoo.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <882887.75491.qm@web65412.mail.ac4.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Andrew Klaassen wrote:

  I've confirmed my earlier results using 2.6.37.5 on the server, though now
  the results are closer to 10 times worse than the Netapp on similar
  hardware rather than 100 times worse.
  
  A big improvement, but I'd still be interested to know if the server is
  capable of the getattr/readdirplus/lookup versus read/write tradeoffs that
  I'm looking for to bring "ls -l" speeds under load down to levels that
  won't make my users yell at me.

What would be nice is if we could add a new system call that would do
roughly what the nfs4 readdir rpc does.  It would take a mask of requested
file attributes, then return those attributes along with the directory
entries.  This would help "ls -l" but would also help all those chatty new
gnome/kde user interface things that love to stat every file in every
directory.
