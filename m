From: "John Z. Bohach" <jzb2-t97x8lR6yknby3iVrkZq2A@public.gmane.org>
Subject: Re: can't modify /etc/exports without blowing away existing clients
Date: Tue, 17 Feb 2009 10:12:06 -0800
Message-ID: <200902171012.07012.jzb2@aexorsyst.com>
References: <200902161220.20474.jzb2@aexorsyst.com> <20090217171404.GB9489@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from host671420017099.direcway.com ([67.142.99.170]:44185 "EHLO
	aexorsyst.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbZBQSNx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 13:13:53 -0500
In-Reply-To: <20090217171404.GB9489@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> No, that shouldn't happen.  As trond says, check whether you have the
> "nfsd" filesystem mounted.

Thanks...got it resolved...squirrly startup script was mounting nfsd fs 
just after it started rpc.statd...

--john
