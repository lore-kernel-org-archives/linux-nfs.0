Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37266 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbaACSFw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jan 2014 13:05:52 -0500
Date: Fri, 3 Jan 2014 13:05:51 -0500
To: lux-integ <lux-integ@btconnect.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: spkm3, pku2u    question
Message-ID: <20140103180551.GA4724@fieldses.org>
References: <201401031543.15051.lux-integ@btconnect.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201401031543.15051.lux-integ@btconnect.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 03, 2014 at 03:43:15PM +0000, lux-integ wrote:
> I have been scanning the Internet to find out if spkm3 has been removed from  
> nfs4 and whether its proported replacement pku2u is available. I get 
> conflicting reports as te the  demise of spkm3 and  most of my endeavours for 
> pku2u seem to suggest it is available now only  as a binary release for  
> microsoft windows.
> 
> 
> I would be grateful for some advice regarding 
> 
> --a) spkm3 status in current releases  of linux kernel and nfs-utils etc.  ( 
> i.e. is it or is it not there and working?)

As far as I know it's all been taken out.  (I know it's out of the
kernel, I don't remember what the status of userland support is--I think
it may never have been merged in the first place.)

> --b) wheher an 'open-source' pku2u for linux is availablea  as replacement for 
> spkm3   and if  so   where to find it.

I don't know of any, or of anyone working on that.

--b.
