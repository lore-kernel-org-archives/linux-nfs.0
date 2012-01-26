Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48588 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab2AZIA1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 03:00:27 -0500
Received: by vbbfc26 with SMTP id fc26so204512vbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jan 2012 00:00:27 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 26 Jan 2012 09:00:26 +0100
Message-ID: <CAAfyv35wM-G0_sFbpZ-829_Lrwz7FNT8hyPeT7XnMzF64YZ6bQ@mail.gmail.com>
Subject: fanotify - fschange filesystem notification on nfs mounted directory
From: Belisko Marek <marek.belisko@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm working on fschange
(http://stefan.buettcher.org/cs/fschange/index.html) on which fanotify
is based also.

It is reporting changes (when file or dir is created, changed, deleted
...) working fine over "normal filesystems".
Our intention is to used to report changes on directory which is
mounted over nfs. This case doesn't work at all
(we got some events about rename only). Is there anything what should
be setup in nfs options or this case basically
didn't work at all? I'm only nfs user and don't understand details.

Thanks in advance,

marek

-- 
as simple and primitive as possible
-------------------------------------------------
Marek Belisko - OPEN-NANDRA
Freelance Developer

Ruska Nova Ves 219 | Presov, 08005 Slovak Republic
Tel: +421 915 052 184
skype: marekwhite
twitter: #opennandra
web: http://open-nandra.com
