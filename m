Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:55254 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab0FWGtm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 02:49:42 -0400
Received: by wwc33 with SMTP id 33so710191wwc.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jun 2010 23:49:41 -0700 (PDT)
Message-ID: <4C21AE7F.9080103@panasas.com>
Date: Wed, 23 Jun 2010 09:49:35 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Yudong Gao <stgyd@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: Supported cluster file system in v4.1
References: <AANLkTilWpNghO37nF9Cmu3F7SxcHU2AI8hKyeDvNSi8d@mail.gmail.com>
In-Reply-To: <AANLkTilWpNghO37nF9Cmu3F7SxcHU2AI8hKyeDvNSi8d@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-06-16 20:17, Yudong Gao wrote:
> Hi,
> 
> We are trying to setup a pNFS testbed and deploy a cluster file system
> on the storage servers. We find that the GFS from RedHat supports
> pNFS. But is there any other cluster file system that also supports
> pNFS?

Yudong, what are you looking for in your tests?
Another option for the pNFS files layout is spnfs which is good for basic testing
but it is experimental and not very well supported currently; i.e. if it breaks
under load you'll probably have to fix it yourself...

You could also consider testing exofs - a loosely clustered, objects-based
file system that provides scalable performance and is stable enough for
rather intensive workloads.

Benny

> 
> Thanks.
> 
> Yudong
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

