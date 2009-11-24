From: Peter Staubach <staubach@redhat.com>
Subject: Re: Apparent race condition w/ NFSv3 mktemp+write+rename
Date: Tue, 24 Nov 2009 15:44:37 -0500
Message-ID: <4B0C45B5.5040008@redhat.com>
References: <hehc8g$k8f$1@ger.gmane.org> <4B0C3BF8.1070904@redhat.com> <4B0C4116.10903@dyfis.net> <4B0C4277.8050004@redhat.com> <4B0C43D5.7000103@dyfis.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Charles Duffy <charles-7s4ginpmXnFeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757808AbZKXUoc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 15:44:32 -0500
In-Reply-To: <4B0C43D5.7000103-7s4ginpmXnFeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Charles Duffy wrote:
> Peter Staubach wrote:
>> Does this take a very long time to run when it fails like this?
>>   
> Total runtime for script invocations where the failure occurred has in
> all cases (two today -- one at 7:59AM, the other at 12:08PM) been less
> than three seconds.

Interesting.  And non-deterministic, I'll bet?

	Thanx...

		ps
