Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:42244 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab2K2Jcf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 04:32:35 -0500
MIME-Version: 1.0
Date: Thu, 29 Nov 2012 10:32:33 +0100
Message-ID: <CANXojcy9thLBwrENTkOTSSE17L3N17A8XsTmyNqq3oNdhW_Q_w@mail.gmail.com>
Subject: Possible to make nfs aware of a inotify watch has been set.
From: Stef Bon <stefbon@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: linux-cifs <linux-cifs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

as far as I know individual filesystems are not aware an inotify watch
has been set on a
inode managed by that filesystem.

For local only filesystems like ext2/3/4 etcetera this is no problem.
But with network filesystems
like nfs and cifs (and also fuse types) this is not ideal, since
changes made by others (since the backend
is shared with others) are never watched.

I'm working on a filesystem change watcher notifyfs, and puzzling
already for a long time howto enable
the watching of fs events on these filesystems.

I've some idea's:

a. notifyfs is working on the local (A) and the remote host (B), and
is doing it's thing without using the filesystem. When a client
contacts notifyfs to set a watch on a nfs (or cifs) share, notifyfs
detects it a nfs share. It finds out the remote host by analyzing the
mount, and gets the details like remote address and directory. With
nfs that's easy, since the mount is like remotehost:/directory, with
cifs this is a bit more difficult, but doable.
After getting the details, it can forward the watch to the remote host
(B), on which also notifyfs is running, and listning to a tcp port.
This notifyfs process on his turn watches the desired fs object using
the abilities on that host, and sends anything back to the local host
(A).

I've experimented with this, and got it working when using sshfs.

This is very easy to setup, and simple to understand, but some drawbacks:

1. while the filesystems are using credentails or tickets to get
access to a remote resource, this is a bit difficult for notifyfs.
Notifyfs bypasses that. Maybe this leads to permissions/abuse I cannot
see directly.

2. the filesystem still does not know that something has changed (on
B). It should be made aware as fast as possible to make the changes
effective on localhost A. Maybe notifyfs should just trigger that by
doing a lookup on an entry when it has been removed on the remote host
for example.

b. notifyfs forwards the watch to nfs (and cifs) using netlink. Since
nfs and cifs are in kernelspace, and notifyfs is in userspace, netlink
is the way to go to communicate.This is possible, and I've thought
this is the best way to go for a long time, but complicated when
compared to the last method:

c.  make filesystems like nfs and cifs aware a inotify watch has been
set. Untill now the filesystems self are totally not notified a watch
has been set (and of course also changed/removed). This is by design.
For local filesystems it's not required, it will not get any extra,
but nfs and cifs and fuse fs's can use this info to set a watch on the
backend using the methods/api specific to the filesystem. For example
cifs will send a SMB2_CHANGE_NOTIFY to the server, and waiting for
results.

What do you think, is the latest option possible??

Stef Bon
