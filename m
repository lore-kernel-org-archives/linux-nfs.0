From: dan carpenter <error27@email.com>
Subject: Re: bad: scheduling while atomic in nfs with 2.6.3
Date: Tue, 2 Mar 2004 20:15:43 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200403022015.43151.error27@email.com>
References: <40454C6F.5020901@matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Mike Fedyk <mfedyk@matchmail.com>,
	LKML <linux-kernel@vger.kernel.org>
In-Reply-To: <40454C6F.5020901@matchmail.com>
List-ID: <nfs.lists.sourceforge.net>

On Tuesday 02 March 2004 07:09 pm, Mike Fedyk wrote:
> I'm running 2.6.3-zonebal-lofft-slabfaz
> Call Trace:
>   [<c012258d>] __might_sleep+0x9d/0xe0
>   [<c01651d8>] deactivate_super+0x58/0x100
>   [<f89e9fba>] svc_export_put+0x7a/0x80 [nfsd]

The bad call path goes something like this:
svc_export_put() -> mntput() ->  __mntput() -> deactivate_super()
-> down_write() -> might_sleep()

I don't have a fix.  Neil Brown might.  I've CC'd him.

regards,
dan carpenter
