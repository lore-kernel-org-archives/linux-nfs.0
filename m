Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:57756 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503Ab1JTQP1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 12:15:27 -0400
Message-ID: <4EA04903.1030300@panasas.com>
Date: Thu, 20 Oct 2011 09:14:59 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Benny Halevy <bhalevy@tonian.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Benny Halevy <benny@tonian.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/7] nfsd4: typo logical vs bitwise negate for want_mask
References: <956652236-1319113365-cardhu_decombobulator_blackberry.rim.net-813536196-@b18.c3.bise3.blackberry> <20111020122601.GK28630@pad.fieldses.org>
In-Reply-To: <20111020122601.GK28630@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/20/2011 05:26 AM, J. Bruce Fields wrote:
> On Thu, Oct 20, 2011 at 12:22:41PM +0000, Benny Halevy wrote:
>> The other patch was for the deny bits this is for the want mask...
>> Similar bug, different place :)
> 
> Oog, sorry!  OK, applying.
> 
> (And in fact I made the same ! for ~ mistake in one other place in the
> last week that got caught by regression testing before I posted it.  I
> need to teach my editor to highlight !'s in blinking red, or
> something....)
> 

That's easy. Imagine your 8th grade teacher's face on the "!" key. The
habit will go away fast.

> --b.
> 

Boaz
