Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753130AbbCKOO1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2015 10:14:27 -0400
Date: Wed, 11 Mar 2015 10:14:23 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Peng Yu <pengyu.ut@gmail.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS hang after concurrent writes
In-Reply-To: <CABrM6w=YWhEHfJmhVxwS3bEGn3vFjysxkay1dXS=iZVumUcpAA@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1503111012530.947@planck.local>
References: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com> <alpine.OSX.2.19.9992.1503100423290.456@planck.local> <CABrM6w=PoXHM9d6oSwsBK0ea7jxoyJ29TV0M_q-71qr_RykCKQ@mail.gmail.com> <alpine.OSX.2.19.9992.1503100735000.456@planck.local>
 <CABrM6w=YWhEHfJmhVxwS3bEGn3vFjysxkay1dXS=iZVumUcpAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="0-830169839-1426083265=:947"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-830169839-1426083265=:947
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 10 Mar 2015, Peng Yu wrote:

>
>
> On Tuesday, March 10, 2015, Benjamin Coddington <bcodding@redhat.com> wrote:
>       On Tue, 10 Mar 2015, Peng Yu wrote:
>
>       >
>       >
>       > On Tuesday, March 10, 2015, Benjamin Coddington <bcodding@redhat.com> wrote:
>       >       On Mon, 9 Mar 2015, Peng Yu wrote:
>       >
>       >       > Hi,
>       >       >
>       >       > I have a home directory from an ubuntu server shared to multiple other
>       >       > ubuntu servers as the home directory (the default login shell is bash
>       >       > on these servers) via NFS (see the following configuration in
>       >       > /etc/exports from the NFS server).
>       >       >
>       >       > /mnt/home 172.17.0.0/16(fsid=2,rw,insecure,no_subtree_check,sync,no_root_squash)
>       >       >
>       >       > autofs is used to mount the NFS on the client servers (see the
>       >       > following configuration).
>       >       >
>       >       > ~$ cat /etc/auto.master
>       >       > +auto.master
>       >       > /home   /etc/auto.home --timeout=90
>       >       > ~$ cat /etc/auto.home
>       >       > *  -fstype=nfs4,rw,intr,fsc    nsfserver:/mnt/home/&
>       >       >
>       >       > But I frequently end up with a situation when ~/.bash_history is not
>       >       > readable which blocks the logins to these client servers. I feel that
>       >       > this may be related with concurrent write to ~/.bash_history from
>       >       > these servers, which somehow screw up NFS.
>       >
>       >       Hi Peng, what do you have that supports your feeling that the problem is
>       >       conflicts on the ~/.bash_history file?  It's hard to help without more
>       >       information.
>       >
>       >
>       > The login process hangs when a line related to ~/.bash_history in ~/.bashrc is being loaded. At that time,
>       cat ~/.bash_history
>       > also hangs, but stat the file works fine. After I delete ~/.bash_history, the login process stops hanging.
>       >
>       > The real difficulty is to reliably repoduce this problem in order to pinpoint the exact cause of the problem with
>       nfs. So far I
>       > only see the problem with ~/.bash_history, it is hard to believe this problem is related with the actual filename. A
>       logic
>       > conclusion is that it must be somehow related with how this file is written.
>
>       A network capture would be a good next step toward finding the problem.
>
>
> I see something like this.
>
> http://wiki.linux-nfs.org/wiki/index.php/General_troubleshooting_recommendations#Capturing_a_Network_Trace
>
> Could you help show the detailed proceedure on how to do network capture to debug this specific issue if there is anything better
> than that in the above instruction ?
>
Those instructions are fine.

Ben
--0-830169839-1426083265=:947--
