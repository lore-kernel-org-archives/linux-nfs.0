Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753234Ab3JVQLD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 12:11:03 -0400
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
From: Simo Sorce <simo@redhat.com>
To: Weston Andros Adamson <dros@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <002FCC76-C58E-4B33-B561-6335AB77AAB4@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
	 ,<1382454148.9794.72.camel@willson.li.ssimo.org>
	 <002FCC76-C58E-4B33-B561-6335AB77AAB4@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Oct 2013 12:11:01 -0400
Message-ID: <1382458261.9794.87.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-10-22 at 15:46 +0000, Weston Andros Adamson wrote:
> 
> gsskeyd is a separate daemon only for proof of concept. In the commit
> message it makes it clear that if this is the way we want to go, it
> should be incorporated into gssd. 
> 
The more I think of the idea the more I think you'd not get what you
want using a daemon that tries to poll files and second guess user
intentions by the way libkrb5 actually operates, you'd probably be
subject to way too many false positives to be useful.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

