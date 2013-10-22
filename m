Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53863 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026Ab3JVQOi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 12:14:38 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
Date: Tue, 22 Oct 2013 16:14:37 +0000
Message-ID: <342171A2-EBEA-4EEA-BE80-19DC4F42B9A0@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
 ,<1382454148.9794.72.camel@willson.li.ssimo.org>
 <002FCC76-C58E-4B33-B561-6335AB77AAB4@netapp.com>
 <1382458261.9794.87.camel@willson.li.ssimo.org>
In-Reply-To: <1382458261.9794.87.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 22, 2013, at 12:11 PM, Simo Sorce <simo@redhat.com>
 wrote:

> On Tue, 2013-10-22 at 15:46 +0000, Weston Andros Adamson wrote:
>> 
>> gsskeyd is a separate daemon only for proof of concept. In the commit
>> message it makes it clear that if this is the way we want to go, it
>> should be incorporated into gssd. 
>> 
> The more I think of the idea the more I think you'd not get what you
> want using a daemon that tries to poll files and second guess user
> intentions by the way libkrb5 actually operates, you'd probably be
> subject to way too many false positives to be useful.
> 

I think you're probably right, but this method works well for testing NFS code under near-to-expiry and expired cred conditions.

-dros