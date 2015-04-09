Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34423 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933003AbbDITe5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2015 15:34:57 -0400
Received: by iedfl3 with SMTP id fl3so743641ied.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Apr 2015 12:34:56 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 9 Apr 2015 15:34:56 -0400
Message-ID: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
Subject: Problems mounting via UDP from a netapp with multiple interfaces
From: Gregory Boyce <gregory.boyce@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Folks,

I've been encountering a problem with NFS clients attempting to mount
from a netapp via UDP where the netapp is responding on the wrong
interface.  On some of our older systems, this mount worked properly,
while on newer systems nfs-utils ends up failing the mount.  Mounting
via TCP works fine.

It appears that there has been various related discussions over the
years, and a relevant Redhat bug opened back in 2006:

http://article.gmane.org/gmane.linux.nfs/22778/match=connect+udp
https://bugzilla.redhat.com/show_bug.cgi?id=208244

Is there a general recommendation for people in this sort of
situation?  I'm assuming the code is currently using connected UDP
sockets (I'm more of a sysadmin than a developer).  Is there an option
I'm missing to disable this?  Otherwise does anyone know of a patch to
change the behavior?

-- 
Greg
