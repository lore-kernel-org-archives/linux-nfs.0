From: Charles Duffy <charles-7s4ginpmXnFeoWH0uzbU5w@public.gmane.org>
Subject: Re: Apparent race condition w/ NFSv3 mktemp+write+rename
Date: Tue, 24 Nov 2009 14:36:37 -0600
Message-ID: <4B0C43D5.7000103@dyfis.net>
References: <hehc8g$k8f$1@ger.gmane.org> <4B0C3BF8.1070904@redhat.com> <4B0C4116.10903@dyfis.net> <4B0C4277.8050004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:48350 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932153AbZKXUkP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2009 15:40:15 -0500
Received: by gxk26 with SMTP id 26so7079123gxk.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2009 12:40:21 -0800 (PST)
In-Reply-To: <4B0C4277.8050004@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter Staubach wrote:
> Does this take a very long time to run when it fails like this?
>   
Total runtime for script invocations where the failure occurred has in 
all cases (two today -- one at 7:59AM, the other at 12:08PM) been less 
than three seconds.
