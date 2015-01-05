Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752827AbbAENOw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 08:14:52 -0500
Message-ID: <54AA8E4A.6060705@RedHat.com>
Date: Mon, 05 Jan 2015 08:14:50 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Yann E. MORIN" <yann.morin.1998@free.fr>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] configure: use pkg-config to find libtirpc
References: <1416755357-12228-1-git-send-email-yann.morin.1998@free.fr>
In-Reply-To: <1416755357-12228-1-git-send-email-yann.morin.1998@free.fr>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 11/23/2014 10:09 AM, Yann E. MORIN wrote:
> Currently, we use a custom function to find libtirpc's headers and
> libraries. This works fine for shared linking.
> 
> But for static linking, this forgets to link with -lpthread, which is
> required by libtirpc.
> 
> A recent patch was sent to libtirpc to add that missing -lpthread in its
> Libs.private section of its .pc file. Thus, pkg-config will soon be able
> to return the appropriate libraries.
> 
> So, use pkg-config to find libtirpc.
> 
> And for older libtirpc versions, there is no change in behaviour: we're
> still missing the -lpthread. But once libtirpc has been fixed, we'll
> automatically get that missing library for free! :-)
> 
> Remove the --with-libirpc flag as it is no longer needed: pkg-config
> will provide us with the -I and -L flags, now.
It turns out that using pkg-config break builds on legacy OSs which
is something I don't want to do. I think it's important to at least 
try to maintain legacy builds so I'm looking to revert this patch. 

So if I revert this patch, what will break in your world? 

steved.
