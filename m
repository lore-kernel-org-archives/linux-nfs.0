Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37678 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936Ab2ADTXK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jan 2012 14:23:10 -0500
Message-ID: <4F04A71A.5040601@RedHat.com>
Date: Wed, 04 Jan 2012 14:23:06 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils release plans
References: <C26A6213-62B0-4E3E-B95E-83EFCDE1B778@oracle.com>
In-Reply-To: <C26A6213-62B0-4E3E-B95E-83EFCDE1B778@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

Just go ahead a post them as soon as you can... Everything that goes into the upstream nfs-utils automatically goes into the Fedora rawhide (which in this case is pre-F17). So if you can post the patches before the 24th, they will automatically be included in f17...

steved.

On 12/23/2011 04:52 PM, Chuck Lever wrote:
> Hi Steve-
> 
> I have a few patches for the next release of nfs-utils, including junction support in mountd.  Since Jeff has queued up fedfs-utils for Fedora 17, mountd junction support will need to go in Fedora 17.  My linux-nfs repo is all lined up, and I can post the patches in e-mail for review whenever you're back from holiday.
> 
> So I don't miss the Fedora 17 feature freeze on January 24, what's your plan for the next upcoming release of nfs-utils?
> 
