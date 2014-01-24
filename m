Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:34589 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbaAXQCP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 11:02:15 -0500
Received: by mail-vc0-f169.google.com with SMTP id hq11so1979716vcb.14
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 08:02:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMFqqRrJPZVz6MPyDH45aQUsL4Jt-5HgMG9PfaLT6nCwdJk8fQ@mail.gmail.com>
References: <CAMFqqRrJPZVz6MPyDH45aQUsL4Jt-5HgMG9PfaLT6nCwdJk8fQ@mail.gmail.com>
Date: Fri, 24 Jan 2014 11:02:14 -0500
Message-ID: <CAMFqqRoh52UrGX2CCfuw0ij-7O7OfY_=a_DnHwrGaT+9OqBa+g@mail.gmail.com>
Subject: Fwd: NFS4: new accounts username = nobody, old accounts fine, reboot fine.
From: Stephen Cousins <steve.cousins@maine.edu>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have the following:

File Server: CentOS 6.3 kernel 2.6.32-279.19.1.el6.x86_64
Head Node:   CentOS 5.7 kernel 2.6.18-275.12.1.el5.573g0000
Backup1:     CentOS 6.5 kernel 2.6.32-431.3.1.el6.x86_64
GPU:         CentOS 6.4 kernel 2.6.32-358.6.2.el6.x86_64


Booting up all machines after the file server is up works fine. All
ID's map fine.

When I add a new user I first add them to the File Server and then I
do it on the other machines. I get a warning that the home directory
has already been created but that is fine. The ID's are consistent
across machines.

After an account is created (kehuang in this case) all is fine on the Head Node:

drwxr-x---   4 kehuang    omg           153 Jan 23 18:54 kehuang
drwxr-x---  32 zwenzhou   omg          4096 Jan 23 18:56 zwenzhou
drwxr-x---  35 mjohnson   forestry     4096 Jan 24 00:26 mjohnson
drwxr-x--- 118 cousins    cousins      8192 Jan 24 10:43 cousins


But on Backup1 and GPU I get "nobody" for the new user:

drwxr-x---   4 nobody     omg           153 Jan 23 15:54 kehuang
drwxr-x---  32 zwenzhou   omg          4096 Jan 23 15:56 zwenzhou
drwxr-x---  35 mjohnson   forestry     4096 Jan 23 21:26 mjohnson
drwxr-x--- 118 cousins    cousins      8192 Jan 24 07:43 cousins

The GID maps fine though, probably because it is not a new group.

I have tried restarting rpcidmapd on the nodes but it doesn't help.
The only thing I have found that works is a reboot.

Has anyone run across this before? Anyone know a solution?  It doesn't
seem to be a idmapd.conf issue since it works fine until a new user is
added.

One odd thing though is that the id maps to 99:nobody instead of
65534:nfsnobody.

Here is what idmapd.conf looks like on all machines:

[General]
Verbosity = 0
Domain = localdomain

[Mapping]
Nobody-User = nfsnobody
Nobody-Group = nfsnobody

[Translation]
Method = nsswitch


Thanks for your help.

Steve
