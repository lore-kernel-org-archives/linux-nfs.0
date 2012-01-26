Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3140 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389Ab2AZPQa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 10:16:30 -0500
Message-ID: <4F216E4C.7030907@netapp.com>
Date: Thu, 26 Jan 2012 10:16:28 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Belisko Marek <marek.belisko@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: fanotify - fschange filesystem notification on nfs mounted directory
References: <CAAfyv35wM-G0_sFbpZ-829_Lrwz7FNT8hyPeT7XnMzF64YZ6bQ@mail.gmail.com>
In-Reply-To: <CAAfyv35wM-G0_sFbpZ-829_Lrwz7FNT8hyPeT7XnMzF64YZ6bQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu Jan 26 03:00:26 2012, Belisko Marek wrote:
> Hi,
>
> I'm working on fschange
> (http://stefan.buettcher.org/cs/fschange/index.html) on which fanotify
> is based also.
>
> It is reporting changes (when file or dir is created, changed, deleted
> ...) working fine over "normal filesystems".
> Our intention is to used to report changes on directory which is
> mounted over nfs. This case doesn't work at all
> (we got some events about rename only). Is there anything what should
> be setup in nfs options or this case basically
> didn't work at all? I'm only nfs user and don't understand details.

You didn't set up anything wrong, the case just doesn't work for 
finding changes on the server.  Files created locally should trigger 
inotify events through the VFS, but tracking changes made on the server 
is more difficult.  Notifications are part of the NFS v4.1 protocol, 
but I don't think anything has been implemented right now.

Maybe something in userland like gamin could help?  
http://people.gnome.org/~veillard/gamin/

- Bryan

>
> Thanks in advance,
>
> marek
>


