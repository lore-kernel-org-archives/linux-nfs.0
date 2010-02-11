Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60485 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756901Ab0BKUi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 15:38:28 -0500
Date: Thu, 11 Feb 2010 15:38:57 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Peter Staubach <staubach@redhat.com>
Cc: iisaman@citi.umich.edu, linux-nfs@vger.kernel.org
Subject: Re: [PATCH pynfs] Allow server to reject maximum commit offsets
Message-ID: <20100211203857.GF3801@fieldses.org>
References: <20100209201231.GC30951@fieldses.org> <4B71E1A4.1070604@redhat.com> <20100209224228.GA1645@fieldses.org> <4B71E572.3020401@redhat.com> <20100209225018.GB1645@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100209225018.GB1645@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 09, 2010 at 05:50:18PM -0500, J. Bruce Fields wrote:
> The tests are primarily meant to test protocol conformance.  So they
> shouldn't be reporting failures on conforming behavior.
> 
> Perhaps it would also be interesting to run the tests in a mode which
> probes and summarizes server characteristics (maximum supported offset,
> supported features, etc.), but that's a job for another day.

Hm, actually another alternative would be just to keep these tests, but
to *always* allow them to succeed.  Or to fail only if the server
returns an error that really is totally wrong.

Even if we don't much care about the results, sending operations with
extreme values for the arguments may still help make sure server's don't
skimp on the range-checking and crash in some lower-level code.

--b.
