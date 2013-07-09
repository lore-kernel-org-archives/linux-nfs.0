Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62030 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752949Ab3GIP47 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 11:56:59 -0400
Message-ID: <51DC32C8.6080504@RedHat.com>
Date: Tue, 09 Jul 2013 11:56:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: support minorversion 1 by default
References: <20130709031928.GN29071@fieldses.org> <20130709150657.GB8281@fieldses.org>
In-Reply-To: <20130709150657.GB8281@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/07/13 11:06, J. Bruce Fields wrote:
> On Mon, Jul 08, 2013 at 11:19:28PM -0400, J. Bruce Fields wrote:
>> > From: "J. Bruce Fields" <bfields@redhat.com>
>> > 
>> > We now have minimal minorversion 1 support; turn it on by default.
>> > 
>> > This can still be turned off with "echo -4.1 >/proc/fs/nfsd/versions".
> I intend this for 3.11, since as far as I can tell we're up to spec and
> the 4.1-specific bugs I know about have been fixed.
Ok... Its on my TODO list but I'll wait a bit until 3.11 hits
the street... 

steved.
