From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS using CacheFS
Date: Fri, 08 Oct 2004 07:22:13 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <41667865.2000804@RedHat.com>
References: <4161B664.70109@RedHat.com> <41661950.5070508@tequila.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net,
	Linux filesystem caching discussion list
	<linux-cachefs@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269852AbUJHL0K@vger.kernel.org>
To: Clemens Schwaighofer <cs@tequila.co.jp>
In-Reply-To: <41661950.5070508@tequila.co.jp>
List-ID: <nfs.lists.sourceforge.net>

Clemens Schwaighofer wrote:

> brr :) why is it posix, this is so out of the context for me (as a
> user). Is it possible to have a cachefs flag. Would make it more logical.

Because it was the easiest way to get things started (i.e. no userlevel
changes needed at all).... The 'fscache' flag will be coming along with
the nfs4 support, since nfs4 mounting code does not have an open
(unused) mounting flag....

SteveD.
