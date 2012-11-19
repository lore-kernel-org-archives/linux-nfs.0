Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20938 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640Ab2KSRWL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Nov 2012 12:22:11 -0500
Message-ID: <50AA6AC1.2080201@netapp.com>
Date: Mon, 19 Nov 2012 12:22:09 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: =?UTF-8?B?TWlsb3ZhbiBLcml2b2thcGnEhw==?=
	<milovan.krivokapic@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Fwd: [Question] NFS and default file / folder permission
References: <CAGXUOGKWDB11zoqZ9zofBgJhJ3Jw0mhZh9QUF8up-1LGCVQ2zw@mail.gmail.com> <CAGXUOG+Px7tBTYH_9e93dOdxUweoE64aLLmRFa4BmyejC9Riug@mail.gmail.com> <CAGXUOGLFKKFOjPXHVhr6j7T_4VNKeai4Bmosu44Lsdbs=XJOdQ@mail.gmail.com>
In-Reply-To: <CAGXUOGLFKKFOjPXHVhr6j7T_4VNKeai4Bmosu44Lsdbs=XJOdQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/19/2012 12:06 PM, Milovan Krivokapić wrote:
> Hi, a quick question:
> I have a problem regarding file permissions on NFS. Umask works for
> new files well, but if I get a file via Skype with permission like 600
> and then I put that file on NFS, it keeps permission 600 thus others
> from a group cant use it at all (I am sharing files via common group).
> 
> So the question is how to enforce some default file / folder
> permission on NFS? So in this example, I put file on NFS as client
> with 600 and it turns into 660 or similar (kind like a mask).

I don't think you can... but the current behavior seems like the right thing to do, since changing permissions on files could create security problems.

The best workaround I can come up with is creating a cron job to change permissions on everything in the directory (or if you're creative enough, just the new files).  Good luck!

- Bryan

> 
> Is it even possible or you have any suggestions?
> Debian 6 is a NFS server, clients are Kubuntu 12.04.1 stations that
> mounted NFS exported folder.
> 
> Thank you very much in advance.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

