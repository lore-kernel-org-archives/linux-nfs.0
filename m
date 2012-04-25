Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:58020 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932415Ab2DYX0a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Apr 2012 19:26:30 -0400
Message-ID: <4F988878.7090703@steve-ss.com>
Date: Thu, 26 Apr 2012 01:27:52 +0200
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: LOOKUP Reply Error:NFS3ERR_NO_ENT
References: <4F986927.9020102@steve-ss.com> <20120425222231.GE3251@fieldses.org>
In-Reply-To: <20120425222231.GE3251@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 26/04/12 00:22, J. Bruce Fields wrote:
> On Wed, Apr 25, 2012 at 11:14:15PM +0200, steve wrote:
>> Sorry:
>> also just seen this:
>>
>> CREATE Reply Error:NFS3ERR_ACCES
>
> What principal are you authenticated as?
>
> --b.
The user principal who owns the home directory. I can see the request 
for nfs on the KDC and the share mounts, the user is placed there but 
alas ro
Cheers
Steve
