Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:57439 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257Ab2CKDcf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Mar 2012 22:32:35 -0500
Message-ID: <4F5C1CCC.7080907@fifthhorseman.net>
Date: Sat, 10 Mar 2012 22:32:28 -0500
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Simo Sorce <simo@redhat.com>, steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] Kill SPKM3 auth method
References: <1331322586-4631-1-git-send-email-simo@redhat.com> <4F5A76CD.9080809@fifthhorseman.net> <20120309215446.GA22068@fieldses.org>
In-Reply-To: <20120309215446.GA22068@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/09/2012 04:54 PM, J. Bruce Fields wrote:
> I think pku2u?  Someone who's following that effort will have to comment
> on how far along it is.

Shouldn't we remove SPKM when PKU2U is implemented then?  It doesn't 
look like we have a replacement for this feature yet, which makes me 
think it isn't really obsolete.

> Understood that people would like such a thing, but alas spkm3 and
> lipkey never quite managed to provide it.

Can you point me to an explanation of what is missing from spkm3 and 
lipkey for this goal?  I'd like to understand this problem space better.

Regards,

	--dkg
