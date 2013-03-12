Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:62919 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab3CLAOD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Mar 2013 20:14:03 -0400
Received: by mail-wg0-f46.google.com with SMTP id fg15so5420287wgb.1
        for <linux-nfs@vger.kernel.org>; Mon, 11 Mar 2013 17:14:01 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 11 Mar 2013 17:07:31 -0700
Message-ID: <CAENQ-b9N0un-VNCdw7m9b4TPuVR39TL4NTPcFjF9F+hXU=3i9A@mail.gmail.com>
Subject: nfs.idmapd not being consulted? (different nobody:nobody uid:gid issue)
From: Amritpal Bath <amrit@transamrit.net>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[ I haven't found an answer to this - the usual nobody:nobody issues
appear to be domainname related and not in play here... ]

What are the conditions where rpc.idmapd should be queried on an NFS
client?  I have a few that appears to be completely ignored, resulting
in /home/* being presented as belonging to nobody:nobody.  The same
configuration is fine on other identically configured boxes.

On two identically configured boxes, the following:
    killall rpc.idmapd && rpc.idmapd -f -vvvv

shows queries during "ls -l /home" on box A, but nothing (ever) on box
B (which is the problematic box).

I have many details from an investigation a few weeks ago, but think
it's prudent to keep the initial email brief.

Here are some of those details:
    - 1 NFS server
    - 10 NFS clients
    - 6 (initially deployed boxes) list /home/* fine.
    - 4 (added later) have the nobody:nobody issue.
    - All CentOS 6.3 (64 bit)
    - All clients installed via same kickstart configs (w/ diff hostname)
    - All servers were reinstalled after the 4 newer nodes were added,
so they should be identical.
    - diff'ing /etc dirs from good vs bad boxes reveals nothing significant.


Thanks


--
Amrit
AIM: ThatComputerGuy
ICQ: 3173735
http://transamrit.net/
