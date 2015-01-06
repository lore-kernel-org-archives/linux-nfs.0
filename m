Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932342AbbAFSpm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2015 13:45:42 -0500
Message-ID: <54AC2D52.8030203@RedHat.com>
Date: Tue, 06 Jan 2015 13:45:38 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Yann E. MORIN" <yann.morin.1998@free.fr>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] configure: use pkg-config to find libtirpc
References: <1416755357-12228-1-git-send-email-yann.morin.1998@free.fr> <54AA8E4A.6060705@RedHat.com> <20150105182322.GB5077@free.fr>
In-Reply-To: <20150105182322.GB5077@free.fr>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/05/2015 01:23 PM, Yann E. MORIN wrote:
> 
> What are those "legacy OSs"? Can I help in finding an adequate solution?
> (note: any Linux distro I can install without problem, I could try to
> give a spin to a *BSD one if really needed, but other "OSes" not so
> much...)
The problem is here... 
    http://www.spinics.net/lists/linux-nfs/msg48570.html

> 
> If at all possible, I would like to keep pkg-config as the default, and
> use the old (or another) method only as a fallback, because pkg-config
> is so much nicer to deal with than trying to cope for all cases
> ourselves. Would that be an acceptable solution for you?
Yes.. I would be more than willing to work out something that works in
both cases.... 

steved.

