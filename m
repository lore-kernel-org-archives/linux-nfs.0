From: "Andrew Dixie" <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Fri, 8 Feb 2008 13:05:38 +1300 (NZDT)
Message-ID: <49534.203.167.214.129.1202429138.squirrel@mail.orcon.net.nz>
References: <20080205090132.GA8286@stro.at>
    <1202248931.12271.18.camel@heimdal.trondhjem.org>
    <003301c86888$ed735a20$0301a8c0@MURTLE>
    <1202310021.12647.6.camel@heimdal.trondhjem.org>
    <55598.203.167.214.129.1202337638.squirrel@mail.orcon.net.nz>
    <1202338699.8549.42.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Andrew Dixie" <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>, linux-nfs@vger.kernel.org,
	"maximilian attems" <max-U9r9yeDMy7A@public.gmane.org>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out3.orcon.net.nz ([219.88.242.31]:34189 "EHLO
	mx5.orcon.net.nz" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755407AbYBHAFl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2008 19:05:41 -0500
Received: from Debian-exim by mx5.orcon.net.nz with local (Exim 4.67)
	(envelope-from <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>)
	id 1JNGkN-0001NQ-HQ
	for linux-nfs@vger.kernel.org; Fri, 08 Feb 2008 13:05:39 +1300
In-Reply-To: <1202338699.8549.42.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I've already got a fix for this bug against 2.6.24. Could you see if it
> applies to your kernel too?

Thanks for this.

My client is 2.6.24 so it obviously applies.
I don't believe the bug is in 2.6.18; and 2.6.22 crashes due to other
problems before I can reproduce this hang.

You didn't specifically ask me to test, and with other obligations over
the next few weeks I'm just happy to know a fix is in the pipeline.

Please let me know if there is anything more you would like from me.

Cheers,
Andrew

