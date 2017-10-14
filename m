Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.bluemarble.net ([204.89.253.70]:34101 "EHLO
        mail.bluemarble.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751138AbdJNXSb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Oct 2017 19:18:31 -0400
To: linux-nfs@vger.kernel.org
From: John Ratliff <john@bluemarble.net>
Subject: nfs group permissions not recognized between linux systems
Message-ID: <0c3db682-8838-d718-471f-3c086c03088b@bluemarble.net>
Date: Sat, 14 Oct 2017 19:11:51 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have been working on trying to setup an NFS server, but my clients 
cannot access the files after mounting.

It seems to be a problem with group permissions, but I can't figure out why.

My server is a debian 9 machine with kernel 4.9.51. If I use a debian 
client, either Debian 8 or Debian 9, everything works fine. However, if 
I try with an Ubuntu 14.04, 16.04, or CentOS 7 client, they cannot 
access the files.

My directory on the server has permissions 2750. It is owned by root 
with ssl-cert as the group. The ssl-cert group ID is 555. I have made 
sure that same group is on all the client machines and has the same ID 
of 555. The users I am trying to have access the files are members of 
this group. Yet I keep getting permission denied.

I have turned off the firewall (both on server and client). I have put 
ALL:ALL in /etc/hosts.allow. The machines are in the same subnet. They 
can ping one another and can SSH freely between them.

I have tried NFS v3 and NFS v4, but this doesn't matter.

This is my /etc/exports

/etc/ssl/wildcard.smithville.com 192.168.1.0/24(rw,sync,no_subtree_check)

I've tried making the Ubuntu 16.04 machine the server and the Debian 
machine the client, but I have the same problem (but Ubuntu to Ubuntu is 
fine, and Ubuntu server to CentOS 7 client works).

I'm not sure how to further troubleshoot.

Thanks for any suggestions.

