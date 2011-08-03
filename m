Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754149Ab1HCRn5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 13:43:57 -0400
Message-ID: <4E3988D9.9070909@RedHat.com>
Date: Wed, 03 Aug 2011 13:43:53 -0400
From: Steve Dickson <SteveD@redhat.com>
To: pebender@san.rr.com
CC: linux-nfs@vger.kernel.org
Subject: Re: problem with the --enable-libmount-mount configure option
References: <4E338DD1.9070704@san.rr.com>
In-Reply-To: <4E338DD1.9070704@san.rr.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/30/2011 12:51 AM, Paul Bender wrote:
> nfs-utils' configure script assumes that when either
> --enable-libmount-mount
> or
> --disable-libmount-mount
> is specified, that libmount should be used. The attached patch fixes the problem for me.
Committed... but in the future please use the proper 
patch format described  in  http://linux.yyz.us/patch-format.html

steved.
