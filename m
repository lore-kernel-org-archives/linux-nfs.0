Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58022 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756714Ab2CLTfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 15:35:08 -0400
Date: Mon, 12 Mar 2012 15:35:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: Simo Sorce <simo@redhat.com>, steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] Kill SPKM3 auth method
Message-ID: <20120312193507.GB7203@fieldses.org>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
 <4F5A76CD.9080809@fifthhorseman.net>
 <20120309215446.GA22068@fieldses.org>
 <4F5C1CCC.7080907@fifthhorseman.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F5C1CCC.7080907@fifthhorseman.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 10, 2012 at 10:32:28PM -0500, Daniel Kahn Gillmor wrote:
> On 03/09/2012 04:54 PM, J. Bruce Fields wrote:
> >Understood that people would like such a thing, but alas spkm3 and
> >lipkey never quite managed to provide it.
> 
> Can you point me to an explanation of what is missing from spkm3 and
> lipkey for this goal?  I'd like to understand this problem space
> better.

Sorry, no.  Maybe somebody else can.

Googling for spkm3 and looking for ietf mailing discussions might be a
starting point.

--b.
