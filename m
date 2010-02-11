From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH pynfs] Allow server to reject maximum commit offsets
Date: Thu, 11 Feb 2010 16:32:33 -0500
Message-ID: <4B747771.40902@redhat.com>
References: <20100209201231.GC30951@fieldses.org> <4B71E1A4.1070604@redhat.com> <20100209224228.GA1645@fieldses.org> <4B71E572.3020401@redhat.com> <20100209225018.GB1645@fieldses.org> <20100211203857.GF3801@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: iisaman@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756720Ab0BKVcl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 16:32:41 -0500
In-Reply-To: <20100211203857.GF3801@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Tue, Feb 09, 2010 at 05:50:18PM -0500, J. Bruce Fields wrote:
>> The tests are primarily meant to test protocol conformance.  So they
>> shouldn't be reporting failures on conforming behavior.
>>
>> Perhaps it would also be interesting to run the tests in a mode which
>> probes and summarizes server characteristics (maximum supported offset,
>> supported features, etc.), but that's a job for another day.
> 
> Hm, actually another alternative would be just to keep these tests, but
> to *always* allow them to succeed.  Or to fail only if the server
> returns an error that really is totally wrong.
> 
> Even if we don't much care about the results, sending operations with
> extreme values for the arguments may still help make sure server's don't
> skimp on the range-checking and crash in some lower-level code.
> 

This sounds reasonable to me.

		ps

