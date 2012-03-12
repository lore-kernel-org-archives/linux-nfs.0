Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:32984 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757817Ab2CLWXt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 18:23:49 -0400
Message-ID: <4F5E7772.9000102@fifthhorseman.net>
Date: Mon, 12 Mar 2012 18:23:46 -0400
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: rate-limiting state manager error messages?
References: <87ty1t4iy1.fsf@pip.fifthhorseman.net> <1331590587.12005.15.camel@lade.trondhjem.org>
In-Reply-To: <1331590587.12005.15.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/12/2012 06:16 PM, Myklebust, Trond wrote:
> Sure. How about the following patch?

I don't have the infrastructure set up to test it right now 
(fortunately, i don't see these kind of failures terribly often), but 
the proposed patch certainly looks reasonable to me.

Thanks for such a quick response!

	--dkg
